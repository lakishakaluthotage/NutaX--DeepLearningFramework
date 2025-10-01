import os
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt


# === CONFIGURATION ===
MODEL_PATH = "FoodClassifierNX_VGG16.h5"
DATASET_PATH = "FOOD101"
CLASSES_FILE = os.path.join(DATASET_PATH, "Classes.txt")
IMG_SIZE = (224, 224)
BATCH_SIZE = 32


# === LOAD CLASS LABELS ===
class_mapping = {}
with open(CLASSES_FILE, "r", encoding="utf-8") as f:
   for line in f:
       parts = line.strip().split()
       if len(parts) < 2 or not parts[0].isdigit():
           continue
       class_id = int(parts[0])
       class_name = " ".join(parts[1:])
       class_mapping[class_id] = class_name
class_names = list(class_mapping.values())
print("✅ Loaded class names from Classes.txt.")


# === LOAD TRAINED MODEL ===
model = load_model(MODEL_PATH)
print("✅ Model loaded successfully.")


# === PREPARE VALIDATION DATA GENERATOR (used as test data) ===
val_datagen = ImageDataGenerator(rescale=1.0 / 255.0, validation_split=0.2)


val_generator = val_datagen.flow_from_directory(
   DATASET_PATH,
   target_size=IMG_SIZE,
   batch_size=BATCH_SIZE,
   class_mode='categorical',
   subset='validation',
   shuffle=False
)


# === EVALUATE MODEL ===
val_loss, val_accuracy = model.evaluate(val_generator, verbose=1)
print(f"\n🧪 Validation Loss: {val_loss:.4f}")
print(f"✅ Validation Accuracy: {val_accuracy * 100:.2f}%")


# === PREDICT AND GENERATE REPORT ===
y_true = val_generator.classes
y_probs = model.predict(val_generator, verbose=1)
y_pred = np.argmax(y_probs, axis=1)


# Get class index mapping in correct order
index_to_class = {v: k for k, v in val_generator.class_indices.items()}
sorted_labels = [class_mapping[int(index_to_class[i])] for i in range(len(index_to_class))]


# Classification Report
print("\n📊 Classification Report:")
report = classification_report(y_true, y_pred, target_names=sorted_labels)
print(report)


# Extract weighted metrics
report_dict = classification_report(y_true, y_pred, output_dict=True)
print("🔍 Weighted Precision:", report_dict['weighted avg']['precision'])
print("🔍 Weighted Recall:", report_dict['weighted avg']['recall'])
print("🔍 Weighted F1-score:", report_dict['weighted avg']['f1-score'])


# Confusion Matrix (optional)
cm = confusion_matrix(y_true, y_pred)
plt.figure(figsize=(10, 8))
plt.imshow(cm, interpolation='nearest', cmap='Blues')
plt.title("Confusion Matrix")
plt.colorbar()
plt.xlabel("Predicted Label")
plt.ylabel("True Label")
plt.show()



















