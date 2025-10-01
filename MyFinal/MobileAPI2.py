# Import Flask to build the web server
from flask import Flask, request, jsonify
# Importing necessary modules to handle file operations
import os
#Importing necessary libraries for numerical operations(np)
import numpy as np
#Importing image handling utilities from TensorFlow Keras
from tensorflow.keras.preprocessing import image
#Importing modules to load the pre-trained models
from tensorflow.keras.models import load_model
#Importing necessary modules to make HTTP requests to APIs
import requests

#Initialize the Flask Application
app = Flask(__name__)

# Defining the path to the food dataset
FOOD101_PATH = "FOOD101"
IMG_SIZE = (224, 224)
MODEL_PATH = "FoodClassifierNX_VGG16.h5"

# Load trained model- validation
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file '{MODEL_PATH}' not found.")
model = load_model(MODEL_PATH)
print("Model loaded successfully!")

# Load class labels from the file
classes_file = os.path.join(FOOD101_PATH, "Classes.txt") #Defines the path to the class file
class_mapping = {}  #Dictionary to store class ID to class name
with open(classes_file, "r", encoding="utf-8") as f:   # Open the classes file
    for line in f:  # Read each line from the file
        parts = line.strip().split()     # Split line into parts
        if len(parts) < 2 or not parts[0].isdigit():    # Skip invalid lines
            continue
        class_id = int(parts[0])    #Extract class ID
        class_name = " ".join(parts[1:])    #Extract class names
        class_mapping[class_id] = class_name    #Add to the dictionary

# Create reverse mapping from class indices to class names
class_indices = {v: k for k, v in enumerate(class_mapping.keys())}  #Reverse mapping
index_to_class = {v: k for k, v in class_indices.items()}   #Index to class mapping

# Function to classify food image
def classify_food(img_path):
    if not os.path.exists(img_path):     # Check if image file exists
        return "Unknown"
    
    img = image.load_img(img_path, target_size=IMG_SIZE)    #Load and resize image
    img_array = image.img_to_array(img) #Convert to numpy array
    img_array = np.expand_dims(img_array, axis=0) / 255.0   #Normalize image data
    preds = model.predict(img_array)    #Predict using the model
    predicted_class_index = np.argmax(preds)    # Get the class with the highest probability
    folder_number = index_to_class.get(predicted_class_index, "Unknown")    # Map to class label
    return class_mapping.get(folder_number, "Unknown")   # Return class name

# Function to get nutritional information
def get_nutritional_info(product_name):
    base_url = "https://world.openfoodfacts.org/api/v0/product/"    # Base URL for API
    search_url = f"https://world.openfoodfacts.org/cgi/search.pl?search_terms={product_name}&search_simple=1&json=1" # Search API endpoint
    
    response = requests.get(search_url) # Perform search request
    if response.status_code == 200:  # Check if the response is successful
        data = response.json()  # Convert response to JSON
        if 'products' in data and len(data['products']) > 0:    #Check for products
            product_code = data['products'][0]['code']  #Get first product code
            product_response = requests.get(base_url + product_code + ".json")  #Fetch Product details
            if product_response.status_code == 200: #Check response status
                product_data = product_response.json()  #Convert to json
                if 'product' in product_data:   #Check if product data is available
                    return {
                        'product_name': product_data['product'].get('product_name', 'N/A'), #Product name
                        'calories': product_data['product']['nutriments'].get('energy-kcal_100g', 'N/A'),   #Calories
                        'proteins': product_data['product']['nutriments'].get('proteins_100g', 'N/A'),  #Proteins
                        'carbohydrates': product_data['product']['nutriments'].get('carbohydrates_100g', 'N/A'),    #Carbohydrates
                        'fats': product_data['product']['nutriments'].get('fat_100g', 'N/A')    #Fats
                    }
    return {"error": "Product not found"}   #Return error if not found

# Define API endpoint for food classification
@app.route("/classify", methods=["POST"])
def classify():
    if "image" not in request.files:
        return jsonify({"error": "No image provided"}), 400
    
    img = request.files["image"]
    img_path = os.path.join("uploads", img.filename)
    img.save(img_path)
    
    predicted_food = classify_food(img_path)
    os.remove(img_path)
    if predicted_food == "Unknown":
        return jsonify({"error": "Could not classify image"}), 400
    
    nutritional_info = get_nutritional_info(predicted_food)     #Get nutrition info
    return jsonify({"predicted_food": predicted_food, "nutrition": nutritional_info})

# Run the Flask app
if __name__ == "__main__":
    if not os.path.exists("uploads"):   # Check if uploads directory exists
        os.makedirs("uploads")      # Create uploads directory
    app.run(host="0.0.0.0", port=5000, debug=True)  # Start the server
