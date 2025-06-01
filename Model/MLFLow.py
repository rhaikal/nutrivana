import mlflow
import pandas as pd
from Model1 import NutritionSystem
from datetime import datetime
import tempfile
import os

def setup_test_case():
    """Get test case interactively from user"""
    print("\n=== INPUT DATA UNTUK KOMPARASI MODEL ===")
    return {
        'age_months': int(input("Umur (bulan): ")),
        'gender': input("Jenis kelamin (Laki-laki/Perempuan): ").strip(),
        'weight_kg': float(input("Berat badan (kg): ")),
        'height_cm': float(input("Tinggi badan (cm): ")),
        'consumed_foods': [
            int(x.strip()) for x in 
            input("Masukkan ID makanan yang sudah dikonsumsi (pisahkan dengan koma): ").split(',')
            if x.strip().isdigit()
        ]
    }

def evaluate_model(model, test_case):
    """Simulate user input and evaluate model"""
    model.current_status = model.classify_status(
        test_case['age_months'],
        test_case['gender'],
        test_case['height_cm'],
        test_case['weight_kg']
    )
    model.current_needs = model.calculate_needs(
        test_case['age_months'],
        model.current_status
    )
    model.consumed_foods = test_case['consumed_foods']
    
    # Get recommendations and evaluate
    recommendations = model.get_recommendations()
    eval_results = model.evaluate_recommendations()
    
    return {
        'recommendations': recommendations,
        'metrics': {
            'precision': eval_results['precision'],
            'recall': eval_results['recall'],
            'num_recommendations': len(recommendations)
        },
        'status': model.current_status,
        'needs': model.current_needs
    }

def log_model_artifacts(model, results):
    """Log model artifacts to MLflow with proper file handling"""
    # Save recommendations to CSV
    with tempfile.NamedTemporaryFile(suffix='.csv', mode='w', delete=False) as temp_file:
        results['recommendations'].to_csv(temp_file.name, index=False)
        temp_file_path = temp_file.name
    
    try:
        mlflow.log_artifact(temp_file_path, "recommendations")
    finally:
        # Ensure file is closed before deletion
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
    
    # Save nutrition needs
    with tempfile.NamedTemporaryFile(suffix='.txt', mode='w', delete=False) as temp_file:
        nutrition_info = "=== Nutrition Needs ===\n"
        nutrition_info += "\n".join([f"{k}: {v}" for k, v in results['needs'].items()])
        temp_file.write(nutrition_info)
        temp_file_path = temp_file.name
    
    try:
        mlflow.log_artifact(temp_file_path, "nutrition_info")
    finally:
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
    
    # Log parameters and metrics
    mlflow.log_params({
        'nutrition_weight': model.nutrition_weight,
        'similarity_weight': model.similarity_weight
    })
    mlflow.log_metrics(results['metrics'])

def log_pyfunc_model(model):
    """Log the model as a pyfunc model"""
    class NutritionModelWrapper(mlflow.pyfunc.PythonModel):
        def load_context(self, context):
            self.model = model
            
        def predict(self, context, model_input):
            # Implement prediction logic here
            return self.model.get_recommendations()
    
    # Log the model
    mlflow.pyfunc.log_model(
        "model",
        python_model=NutritionModelWrapper(),
        artifacts={},
        registered_model_name="NutritionRecommendationSystem"
    )

def run_comparison():
    """Main comparison function with interactive input"""
    # Setup MLflow tracking
    mlflow.set_tracking_uri("sqlite:///mlflow.db")
    mlflow.set_experiment("Nutrition_Model_Comparison")
    
    # Get user input
    test_case = setup_test_case()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Define model variants to compare
    model_variants = [
        {
            'name': f"Prioritas_Nutrisi_{timestamp}",
            'params': {'nutrition_weight': 0.8, 'similarity_weight': 0.2},
            'description': "Fokus 80% pada nutrisi, 20% kesamaan bahan"
        },
        {
            'name': f"Seimbang_{timestamp}",
            'params': {'nutrition_weight': 0.5, 'similarity_weight': 0.5},
            'description': "Bobot seimbang 50-50"
        },
        {
            'name': f"Prioritas_Bahan_{timestamp}",
            'params': {'nutrition_weight': 0.2, 'similarity_weight': 0.8},
            'description': "Fokus 80% pada kesamaan bahan"
        }
    ]
    
    for variant in model_variants:
        with mlflow.start_run(run_name=variant['name']):
            print(f"\nEvaluating model: {variant['description']}")
            
            # Initialize model with tags
            mlflow.set_tags({
                'model_type': 'NutritionRecommendation',
                'description': variant['description'],
                'test_case_age': str(test_case['age_months']),
                'test_case_gender': test_case['gender'],
                'test_case_weight': str(test_case['weight_kg']),
                'test_case_height': str(test_case['height_cm']),
                'test_case_foods': ','.join(map(str, test_case['consumed_foods']))
            })

            
            model = NutritionSystem(
                nutrition_weight=variant['params']['nutrition_weight'],
                similarity_weight=variant['params']['similarity_weight']
            )
            
            # Evaluate
            results = evaluate_model(model, test_case)
            
            # Log everything to MLflow
            log_model_artifacts(model, results)
            log_pyfunc_model(model)
            
            # Print summary
            print(f"\n=== Hasil evaluasi untuk {variant['name']} ===")
            print(f"- Precision: {results['metrics']['precision']:.2f}")
            print(f"- Recall: {results['metrics']['recall']:.2f}")
            print(f"- Jumlah rekomendasi: {results['metrics']['num_recommendations']}")
            print(f"- Status Gizi: {results['status']}")
            print("\nContoh Rekomendasi:")
            print(results['recommendations'][['id', 'nama']].head(3).to_string(index=False))

if __name__ == "__main__":
    run_comparison()