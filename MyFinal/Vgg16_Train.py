import os
import numpy as np
#Importing image processing from TensorFlow Keras
from tensorflow.keras.preprocessing.image import ImageDataGenerator
#Importing pre-trained VGG16 model from keras applications
from tensorflow.keras.applications.vgg16 import VGG16
from tensorflow.keras import layers, models
from tensorflow.keras.optimizers import Adam
from sklearn.metrics import confusion_matrix, classification_report
import matplotlib.pyplot as plt

# Defining the path to the food dataset
FOOD101_PATH = "FOOD101"

#-------Setting up parameters for image preprocessing and training---------------------------------------------------------#
# Resize images to 224x224 pixels for consistency during model training, defines the no of images in a batch for training  #
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 400

# Path to the classes file containing class names
classes_file = os.path.join(FOOD101_PATH, "Classes.txt")

# Dictionary to store class ID and name mapping
class_mapping = {}

# class names from the Classes.txt file
with open(classes_file, "r", encoding="utf-8") as f:
    for line in f:
        parts = line.strip().split() # Split each line into parts

        # Check if the line contains a valid class ID and name
        if len(parts) < 2 or not parts[0].isdigit():
            continue  # Skip invalid lines

        class_id = int(parts[0]) # Extract class ID as an integer
        class_name = " ".join(parts[1:])  # Extract class name
        class_mapping[class_id] = class_name # Store the mapping in the dictionary

print("Loaded Class Names:", class_mapping)


# ----Defining an ImageDataGenerator instance to handle data augmentation and preprocessing -----------------------#
#     Normalize pixel values for training efficiency                                                               #
#     Data augmentation by rotating images up to 30 degrees, shifting images horizontally and vertically by 20%    #
#     Adding shear transformation, zooming in/out by 20% and flipping images horizontally                          #
train_datagen = ImageDataGenerator(
    rescale=1.0 / 255.0,
    rotation_range=30,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    validation_split=0.2     # Reserve 20% of data for validation
)

# ---Creating the training data generator-----------------------------------------------------------------------#
#    Loads images directly from the directory, resize the images, defines the number of images per batch        #
train_generator = train_datagen.flow_from_directory(
    FOOD101_PATH,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical', # Use categorical mode for multi-class classification
    subset='training'         # Uses 80% of the dataset for training
)
# ---Creating the validation data generator-----------------------------------------------------------------------#
#    Loads images directly from the directory, resize the images, defines the number of images per batch          #
val_generator = train_datagen.flow_from_directory(
    FOOD101_PATH,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation'
)

# Map class indices to class names
class_indices = train_generator.class_indices
num_classes = len(class_indices)

# Reverse mapping from index to class ID
index_to_class = {v: int(k) for k, v in class_indices.items()}  # Map folder name to integer ID

# Load the pre-trained VGG16 model without the top classification layer
base_model = VGG16(weights='imagenet', include_top=False, input_shape=(224, 224, 3))

# Freeze the layers of the base model to retain pre-trained weights
for layer in base_model.layers:
    layer.trainable = False

#--------------Build a custom classification model using the VGG16 base----------------------------------------#
#   Adds the pre-trained VGG16 model as the base, then add the global pooling layer to reduce dimensions       #
#   Add the fully connected layer with ReLU activation, dropout layer to prevent overfitting                   #
model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(512, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(num_classes, activation='softmax')     # Output layer with softmax for multi-class classification
])

# Compile the model with Adam optimizer and categorical cross-entropy loss
model.compile(optimizer=Adam(learning_rate=0.0001),
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Model Summary
model.summary()

# Train the model using the training and validation generators
history = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=EPOCHS
)

# Save the trained model to disk
model.save("FoodClassifierNX_VGG16.h5")
print("Model saved successfully!")

# Plotting training and validation accuracy and loss over epochs to visualize the model's performance during training-----#
plt.figure(figsize=(12, 4))

# Plotting the accuracy for both training and validation sets
plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'], label='Training Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()
plt.title('Training and Validation Accuracy')

# Plotting the loss for both training and validation sets
plt.subplot(1, 2, 2)
plt.plot(history.history['loss'], label='Training Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.title('Training and Validation Loss')
plt.show()

#--------Generate Confusion Matrix---------------------------------------------#
y_true = []
y_pred = []
for batch, labels in val_generator:
    preds = model.predict(batch)
    y_true.extend(np.argmax(labels, axis=1))
    y_pred.extend(np.argmax(preds, axis=1))
    if len(y_true) >= val_generator.samples:
        break   # Stop if all validation samples are processed

cm = confusion_matrix(y_true, y_pred)
print("Confusion Matrix:")

#------------Generate Classification Report-----------------------------------------#
report = classification_report(y_true, y_pred, target_names=list(class_mapping.values()))
print("Classification Report:")
print(report)

# Plotting the confusion matrix
plt.figure(figsize=(10, 8))
plt.imshow(cm, interpolation='nearest', cmap='Blues')
plt.title('Confusion Matrix')
plt.colorbar()
plt.xlabel('Predicted Label')
plt.ylabel('True Label')
plt.show()

#Output the precision, recall and f1-score
report_dict = classification_report(y_true, y_pred, output_dict=True)

print("Weighted Precision:", report_dict['weighted avg']['precision'])
print("Weighted Recall:", report_dict['weighted avg']['recall'])
print("Weighted F1-score:", report_dict['weighted avg']['f1-score'])
