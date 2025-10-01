# NutraX - Deep Learning based framework for Real-Time Nutritional Estiamtion
This repository contains the implementation of NutraX, a deep learning-based system developed as part of the final year dissertation for the BEng Software Engineering degree at the University of Westminster (in collaboration with IIT, Sri Lanka).

NutraX is designed to estimate the nutritional content of food in real-time from images, helping users track calories and macronutrients automatically with minimal input.

Modern dietary tracking applications often rely on manual data entry, which is time-consuming and error-prone. NutraX addresses this limitation by leveraging Convolutional Neural Networks (CNNs) for food recognition and portion estimation, integrated with a nutrition database to provide instant results.

Key features:

Real-time food recognition using CNNs (VGG16 architecture with transfer learning).
Accurate nutritional estimation (calories, proteins, carbs, fats).
Data preprocessing with augmentation (rotation, zoom, flipping) to improve generalization.
Optimized for mobile performance using lightweight models and server-based inference.
User-friendly mobile app interface with authentication (Firebase).

🛠️ Tech Stack

Backend / Model: Python, TensorFlow, Keras, NumPy, Pandas, OpenCV
Mobile App: Flutter (for cross-platform support)
Database: Firebase Authentication, Nutrition datasets (FoodData Central, Nutrition5K)
Deployment: Flask API for serving the trained model
Visualization: Matplotlib, Seabor
