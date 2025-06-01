import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel, cosine_similarity

class NutritionSystem:
    NUTRITION_FEATURES = ["energy", "protein", "fat", "carbohydrate", "calcium", "iron"]
    
    def __init__(self, nutrition_weight=0.8, similarity_weight=0.2):
        """Initialize the system with food database and nutrition rules"""
        self.food_db = self._init_food_database()
        self.nutrition_rules = self._init_nutrition_rules()
        self.current_status = None
        self.current_needs = None
        self.consumed_foods = []

        # Initialize TF-IDF vectorizer for ingredient similarity
        self.tfidf_vectorizer = TfidfVectorizer(tokenizer=self._tokenize_ingredients)
        self.ingredient_vectors = self._prepare_ingredient_vectors()

        # Configurable weights
        self.nutrition_weight = nutrition_weight
        self.similarity_weight = similarity_weight

    # --------------------------
    # Initialization Methods
    # --------------------------

    def _tokenize_ingredients(self, text):
        """Custom tokenizer for ingredient processing"""
        if isinstance(text, str):
            return [word.strip().lower() for word in text.split(',')]
        return []
    
    def _prepare_ingredient_vectors(self):
        """Prepare TF-IDF vectors for ingredient similarity"""
        ingredients = self.food_db['bahan'].fillna('').tolist()
        tfidf_matrix = self.tfidf_vectorizer.fit_transform(ingredients)
        return tfidf_matrix
    
    def _init_food_database(self):
        """Load food database from CSV file"""
        # Load the CSV file
        df = pd.read_csv('data_makanan.csv')

        # Rename columns to match our system's naming convention
        df = df.rename(columns={
            'f_id': 'id',
            'f_name': 'nama',
            'energy': 'energy',
            'protein': 'protein',
            'fat': 'fat',
            'carbohydrate': 'carbohydrate',
            'calcium': 'calcium',
            'iron': 'iron',
            'i_names': 'bahan'
        })

        # Select only the columns we need
        df = df[['id', 'nama', 'energy', 'protein', 'fat', 'carbohydrate', 'calcium', 'iron', 'bahan']]
        
        return df
    
    def _init_nutrition_rules(self):
        """Initialize nutrition rules based on nutritional status"""
        return {
            "Gizi buruk (severely wasted)": {
                "prioritas": ["energy", "protein", "iron"],
                "faktor": {
                    "energy": 1.4,  # 40% more energy
                    "protein": 1.5,  # 50% more protein
                    "iron": 1.5,  # 50% more iron
                    "default": 1.0  # No adjustment for others
                }
            },
            "Gizi kurang (wasted)": {
                "prioritas": ["energy", "protein"],
                "faktor": {
                    "energy": 1.2,  # 20% more energy
                    "protein": 1.3,  # 30% more protein
                    "default": 1.0  # No adjustment for others
                }
            },
            "Gizi baik (normal)": {
                "prioritas": ["protein", "calcium"],
                "faktor": {
                    "protein": 1.0,  # 10% more protein
                    "calcium": 1.0,  # 10% more calcium
                    "default": 1.0  # No adjustment for others
                }
            },
            "Berisiko gizi lebih (possible risk of overweight)": {
                "prioritas": ["fat", "carbohydrate"],
                "faktor": {
                    "fat": 0.85,  # 15% less fat
                    "carbohydrate": 0.9,  # 10% less carbs
                    "default": 1.0  # No adjustment for others
                }
            },
            "Gizi lebih (overweight)": {
                "prioritas": ["fat", "carbohydrate"],
                "faktor": {
                    "fat": 0.8,  # 20% less fat
                    "carbohydrate": 0.85,  # 15% less carbs
                    "default": 1.0  # No adjustment for others
                }
            },
            "Obesitas (obese)": {
                "prioritas": ["fat", "carbohydrate"],
                "faktor": {
                    "fat": 0.7,  # 30% less fat
                    "carbohydrate": 0.8,  # 20% less carbs
                    "default": 1.0  # No adjustment for others
                }
            }
        }

    # --------------------------
    # Core Calculation Methods
    # --------------------------
    
    def classify_status(self, usia_bulan, jenis_kelamin, tinggi_cm, berat_kg):
        """Classify nutritional status based on WHO standards"""
        data_z = load_who_zscores(usia_bulan, jenis_kelamin, tinggi_cm)

        if berat_kg < data_z['SD-3']:
            status = "Gizi buruk (severely wasted)"
        elif data_z['SD-3'] <= berat_kg < data_z['SD-2']:
            status = "Gizi kurang (wasted)"
        elif data_z['SD-2'] <= berat_kg <= data_z['SD+1']:
            status = "Gizi baik (normal)"
        elif data_z['SD+1'] < berat_kg <= data_z['SD+2']:
            status = "Berisiko gizi lebih (possible risk of overweight)"
        elif data_z['SD+2'] < berat_kg <= data_z['SD+3']:
            status = "Gizi lebih (overweight)"
        else:
            status = "Obesitas (obese)"

        return status
    
    def calculate_needs(self, umur_bulan, status):
        """Calculate daily nutritional needs based on age and status"""
        # Base nutritional needs by age group (updated values)
        base_needs = {
            "0-5": {
                "energy": 550,  # kcal
                "protein": 9,  # g
                "fat": 31,    # g (40% of energy)
                "carbohydrate": 59,  # g (45% of energy)
                "calcium": 200,  # mg
                "iron": 0.3  # mg
            },
            "6-11": {
                "energy": 800,  # kcal
                "protein": 15,  # g
                "fat": 35,    # g (45% of energy)
                "carbohydrate": 105,  # g (45% of energy)
                "calcium": 270,  # mg
                "iron": 11   # mg
            },
            "12-36": {
                "energy": 1350,  # kcal
                "protein": 20,   # g
                "fat": 45,    # g (40% of energy)
                "carbohydrate": 215,  # g (45% of energy)
                "calcium": 650,  # mg
                "iron": 7    # mg
            },
            "37-60": {
                "energy": 1400,  # kcal
                "protein": 25,   # g
                "fat": 50,     # g (35% of energy)
                "carbohydrate": 220,  # g (45% of energy)
                "calcium": 1000,  # mg
                "iron": 10   # mg
            }
        }
        
        # Determine age group
        if umur_bulan < 6:
            needs = base_needs["0-5"].copy()
        elif umur_bulan < 12:
            needs = base_needs["6-11"].copy()
        elif umur_bulan > 11 and umur_bulan < 37:
            needs = base_needs["12-36"].copy()
        else:
            needs = base_needs["37-60"].copy()
        
        # Apply adjustment factors based on nutritional status
        status_rules = self.nutrition_rules[status]
        for nutrient in needs:
            if nutrient in status_rules["faktor"]:
                needs[nutrient] *= status_rules["faktor"][nutrient]
            else:
                needs[nutrient] *= status_rules["faktor"]["default"]
        
        return needs
    
    def get_recommendations(self):
        """Get personalized food recommendations prioritizing nutrients with highest remaining needs (percentage)"""
        remaining = self.get_remaining_needs()
        
        # 1. Calculate remaining needs as percentage of daily needs
        remaining_percentage = {
            nutrisi: (remaining[nutrisi] / self.current_needs[nutrisi]) if self.current_needs[nutrisi] > 0 else 0
            for nutrisi in self.NUTRITION_FEATURES
        }
        
        # 2. Filter out already consumed foods
        filtered_food = self.food_db[~self.food_db['id'].isin(self.consumed_foods)].copy()
        
        # 3. Calculate ingredient similarity if there's consumption history
        if self.consumed_foods:
            consumed_indices = self.food_db[self.food_db['id'].isin(self.consumed_foods)].index
            avg_ingredient_similarity = np.mean([
                linear_kernel(self.ingredient_vectors[idx:idx+1], 
                            self.ingredient_vectors[filtered_food.index])[0] 
                for idx in consumed_indices
            ], axis=0)
            filtered_food['ingredient_similarity'] = avg_ingredient_similarity
        else:
            filtered_food['ingredient_similarity'] = 0
        
        # 4. Find top 3 nutrients with highest remaining percentage needs
        sorted_remaining = sorted(remaining_percentage.items(), key=lambda x: x[1], reverse=True)
        top_nutrients = [nutrient for nutrient, percentage in sorted_remaining[:3] if percentage > 0]
        
        # 5. Calculate nutrition score based on top needed nutrients (using percentage)
        if top_nutrients:
            # Calculate weighted sum where weights are the remaining percentages
            filtered_food['nutrition_score'] = sum(
                filtered_food[nutrient] * remaining_percentage[nutrient] 
                for nutrient in top_nutrients
            )
            
            # Normalize scores to 0-1 range
            max_score = filtered_food['nutrition_score'].max()
            if max_score > 0:
                filtered_food['nutrition_score'] /= max_score
        else:
            filtered_food['nutrition_score'] = 0
        
        # 6. Calculate hybrid score (80% nutrition needs, 20% ingredient similarity)
        filtered_food['hybrid_score'] = (
            filtered_food['nutrition_score'] * self.nutrition_weight + 
            filtered_food['ingredient_similarity'] * self.similarity_weight
        )
        
        # 7. Return top 5 recommendations
        return filtered_food.sort_values('hybrid_score', ascending=False).head(5)

    # --------------------------
    # User Interaction Methods
    # --------------------------
    
    def run(self):
        """Main interaction loop"""
        self._collect_user_input()
        
        # Initial nutrition assessment
        print(f"\nStatus Gizi: {self.current_status}")
        self._show_daily_needs()
        
        # Food consumption flow
        self._handle_food_consumption()

    def _collect_user_input(self):
        """Collect basic user information"""
        print("\n=== SISTEM REKOMENDASI GIZI ANAK USIA (0-60 BULAN) ===")
        print("\n[INPUT DATA ANAK]")
        umur_bulan = int(input("Umur (bulan): "))
        jenis_kelamin = input("Jenis kelamin (Laki-laki/Perempuan): ")
        berat = float(input("Berat badan (kg): "))
        tinggi = float(input("Tinggi badan (cm): "))
        
        self.current_status = self.classify_status(umur_bulan, jenis_kelamin, tinggi, berat)
        self.current_needs = self.calculate_needs(umur_bulan, self.current_status)

    def _handle_food_consumption(self):
        """Handle the food consumption flow"""
        if input("\nApakah anak anda sudah makan hari ini? (sudah/belum): ").lower() == 'sudah':
            self._record_consumed_foods()
        
        self.show_nutrition_progress()
        
        while input("\nApakah anak anda mau makan lagi? (ya/tidak): ").lower() == 'ya':
            self._provide_recommendations()
            self.show_nutrition_progress()
            
            if self.check_nutrition_fulfilled():
                print("\n>>> Selamat! Kebutuhan gizi harian telah terpenuhi!")
                break

    # --------------------------
    # Display Methods
    # --------------------------
    
    def _show_daily_needs(self):
        """Show daily nutritional needs"""
        print("\nKebutuhan Gizi Harian:")
        for k, v in self.current_needs.items():
            print(f"- {k}: {v:.2f} {'kcal' if k == 'energy' else 'g' if k in ['protein', 'fat', 'carbohydrate'] else 'mg'}")

    def show_nutrition_progress(self):
        """Show current nutrition progress with warnings inline"""
        consumed = self._calculate_consumed()
        print("\n[PROGRESS GIZI SAAT INI]")
        
        for nutrisi in self.NUTRITION_FEATURES:
            persen = consumed.get(nutrisi, 0)/self.current_needs[nutrisi]*100
            status = "✓" if persen >= 90 else "✗"
            
            warning = ""
            if persen > 100:
                warning = " ⚠️ (Cukup, tidak perlu tambahan!)"
                
            print(f"{status} {nutrisi}: {consumed.get(nutrisi, 0):.1f}/{self.current_needs[nutrisi]:.1f} ({persen:.1f}%){warning}")

    def _show_food_info(self, food):
        """Display complete nutritional information for a food item including ingredients"""
        print(f"\n{food['id']}. {food['nama']}:")
        print("Bahan dasar:")
        print(f"- {food['bahan']}")
        print("Informasi Gizi:")
        print(f"- energy: {food['energy']} kcal")
        print(f"- protein: {food['protein']} g")
        print(f"- fat: {food['fat']} g")
        print(f"- carbohydrate: {food['carbohydrate']} g")
        print(f"- calcium: {food['calcium']} mg")
        print(f"- iron: {food['iron']} mg")

    # --------------------------
    # Helper Methods
    # --------------------------
    
    def _record_consumed_foods(self):
        """Record foods that have been consumed"""
        print("\nMakanan yang tersedia:")
        print(self.food_db[['id', 'nama']].to_string(index=False))
        
        while True:
            try:
                makanan_ids = [int(id.strip()) for id in input("Masukkan ID makanan yang sudah dimakan :")]
                for id in makanan_ids:
                    if not self.add_consumed_food(id):
                        print(f"ID makanan {id} tidak valid!")
                break
            except ValueError:
                print("Masukkan ID yang valid (angka)!")
    
    def evaluate_recommendations(self, k=3):
        """
        Evaluate recommendations using precision@k and recall@k based on remaining nutritional needs
        with 35% threshold for relevance
        """
        remaining_needs = self.get_remaining_needs()
        
        # Calculate remaining needs as percentage of daily needs
        remaining_percentage = {
            nutrisi: (remaining_needs[nutrisi] / self.current_needs[nutrisi]) if self.current_needs[nutrisi] > 0 else 0
            for nutrisi in self.NUTRITION_FEATURES
        }
        
        # Get top 3 nutrients with highest remaining percentage needs
        sorted_needs = sorted(remaining_percentage.items(), key=lambda x: x[1], reverse=True)
        top_nutrients = [nutrient for nutrient, percentage in sorted_needs[:3] if percentage > 0]
        
        if not top_nutrients:
            return {
                "precision": 1.0, 
                "recall": 1.0,
                "top_nutrients": [],
                "nutrient_coverage": {}
            }
        
        # Get actual recommendations (top 5)
        recommendations = self.get_recommendations().head(k)
        
        # Calculate how many recommended foods are good for each top nutrient
        nutrient_scores = {nutrient: 0 for nutrient in top_nutrients}
        
        for _, food in recommendations.iterrows():
            for nutrient in top_nutrients:
                # Consider a food good for a nutrient if it provides at least 35% of daily need
                if food[nutrient] >= 0.35 * self.current_needs[nutrient]:
                    nutrient_scores[nutrient] += 1
        
        # Calculate precision and recall
        # precision: fraction of recommended foods that are relevant to any top nutrient
        relevant_foods = 0
        for _, food in recommendations.iterrows():
            for nutrient in top_nutrients:
                if food[nutrient] >= 0.35 * self.current_needs[nutrient]:
                    relevant_foods += 1
                    break
        
        precision = relevant_foods / k
        
        # recall: fraction of top nutrients that are covered by at least one recommended food
        recall = sum(1 for nutrient in top_nutrients if nutrient_scores[nutrient] > 0) / len(top_nutrients)
        
        return {
            "precision": precision,
            "recall": recall,
            "top_nutrients": top_nutrients,
            "nutrient_coverage": nutrient_scores
        }

    def _provide_recommendations(self):
        """Provide and handle food recommendations with evaluation"""
        print("\nRekomendasi makanan untuk anak anda (5 teratas):")
        recommendations = self.get_recommendations()
        
        for idx, row in recommendations.iterrows():
            self._show_food_info(row)
            print()  # Add empty line between recommendations
        
        # Evaluate recommendations
        eval_results = self.evaluate_recommendations()
        print("\nEvaluasi Rekomendasi:")
        print(f"- Nutrisi prioritas: {', '.join(eval_results['top_nutrients'])}")
        print(f"- precision: {eval_results['precision']*100:.1f}% (relevansi makanan yang direkomendasikan)")
        print(f"- recall: {eval_results['recall']*100:.1f}% (cakupan nutrisi prioritas)")
        
        while True:
            try:
                pilihan = int(input("\nMasukkan ID makanan yang akan dikonsumsi (0 untuk batal): "))
                if pilihan == 0:
                    break
                if not self.add_consumed_food(pilihan):
                    print("ID makanan tidak valid.")
                else:
                    break
            except ValueError:
                print("Masukkan angka yang valid!")

    def check_nutrition_fulfilled(self):
        """Check if all nutritional needs are fulfilled"""
        consumed = self._calculate_consumed()
        return all(consumed.get(n, 0) >= self.current_needs[n] for n in self.NUTRITION_FEATURES)

    def get_remaining_needs(self):
        """Calculate remaining nutritional needs"""
        consumed = self._calculate_consumed()
        return {
            nutrisi: max(0, self.current_needs[nutrisi] - consumed.get(nutrisi, 0))
            for nutrisi in self.NUTRITION_FEATURES
        }

    def _calculate_consumed(self):
        """Calculate consumed nutrients"""
        if not self.consumed_foods:
            return {nutrisi: 0 for nutrisi in self.NUTRITION_FEATURES}
        consumed = self.food_db[self.food_db['id'].isin(self.consumed_foods)][self.NUTRITION_FEATURES].sum()
        return consumed.to_dict()

    def add_consumed_food(self, food_id):
        """Add a food to consumed foods list"""
        if food_id in self.food_db['id'].values:
            self.consumed_foods.append(food_id)
            return True
        return False

def load_who_zscores(age_months, gender, height_cm):
        # Menentukan file yang akan dibaca berdasarkan usia dan jenis kelamin
    if age_months <= 24:
        if gender.lower() == 'laki-laki':
            file_path = 'wfl_boys_0-to-2-years_zscores.xlsx'
            height_col = 'Length'  # Untuk usia 0-2 tahun menggunakan kolom 'Length'
        else:
            file_path = 'wfl_girls_0-to-2-years_zscores.xlsx'
            height_col = 'Length'
    else:
        if gender.lower() == 'laki-laki':
            file_path = 'wfh_boys_2-to-5-years_zscores.xlsx'
            height_col = 'Height'  # Untuk usia 2-5 tahun menggunakan kolom 'Height'
        else:
            file_path = 'wfh_girls_2-to-5-years_zscores.xlsx'
            height_col = 'Height'

    # Membaca file Excel
    try:
        df = pd.read_excel(file_path)
        
        if height_col not in df.columns:
            raise ValueError(f"Kolom {height_col} tidak ditemukan dalam file Excel")
            
        df['diff'] = abs(df[height_col] - height_cm)
        closest_row = df.loc[df['diff'].idxmin()]
        
        return {
            'SD-3': closest_row['SD2neg'],
            'SD-2': closest_row['SD2neg'],
            'SD-1': closest_row['SD1neg'],
            'Median': closest_row['SD0'],
            'SD+1': closest_row['SD1'],
            'SD+2': closest_row['SD2'],
            'SD+3': closest_row['SD3']
        }
        
    except FileNotFoundError:
        raise FileNotFoundError(f"File tidak ditemukan: {file_path}")
    except Exception as e:
        raise ValueError(f"Gagal memproses file Excel: {str(e)}")

if __name__ == "__main__":
    system = NutritionSystem()
    system.run()