import mlflow
import pandas as pd
from Model1 import NutritionSystem
from datetime import datetime

def setup_test_case():
    """Get test case interactively from user"""
    print("\n=== INPUT DATA UNTUK KOMPARASI MODEL ===")
    return {
        'age_months': int(input("Umur (bulan): ")),
        'gender': input("Jenis kelamin (Laki-laki/Perempuan): "),
        'weight_kg': float(input("Berat badan (kg): ")),
        'height_cm': float(input("Tinggi badan (cm): ")),
        'consumed_foods': [
            int(x) for x in 
            input("Masukkan ID makanan yang sudah dikonsumsi: ")
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

def log_to_mlflow(run_name, model_params, results):
    """Log results to MLflow"""
    mlflow.log_params(model_params)
    mlflow.log_metrics(results['metrics'])
    
    # Log example recommendations
    mlflow.log_text(
        results['recommendations'][['id', 'nama']].to_string(),
        "recommendations.txt"
    )
    
    # Log nutrition info
    nutrition_info = "\n".join([f"{k}: {v}" for k, v in results['needs'].items()])
    mlflow.log_text(nutrition_info, "nutrition_needs.txt")

def run_comparison():
    """Main comparison function with interactive input"""
    mlflow.set_tracking_uri("sqlite:///mlflow.db")
    mlflow.set_experiment("Nutrition_Model_Comparison")
    
    # Dapatkan input user
    test_case = setup_test_case()  # Sekarang sudah interaktif
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
            'description': "Fokus 70% pada kesamaan bahan"
        }
    ]
    
    for variant in model_variants:
        with mlflow.start_run(run_name=variant['name']):
            print(f"\nEvaluating model: {variant['description']}")
            
            # Initialize model
            model = NutritionSystem(
                nutrition_weight=variant['params']['nutrition_weight'],
                similarity_weight=variant['params']['similarity_weight']
            )
            
            # Evaluate
            results = evaluate_model(model, test_case)
            
            # Log to MLflow
            log_data = {
                **variant['params'],
                'description': variant['description'],
                'test_case': str(test_case)
            }
            log_to_mlflow(variant['name'], log_data, results)
            
            # Print summary
            print(f"Hasil evaluasi untuk {variant['name']}:")
            print(f"- precision: {results['metrics']['precision']:.2f}")
            print(f"- recall: {results['metrics']['recall']:.2f}")
            print(f"- Status Gizi: {results['status']}")
            print("Contoh Rekomendasi:")
            print(results['recommendations'][['id', 'nama']].head(2))

if __name__ == "__main__":
    run_comparison()