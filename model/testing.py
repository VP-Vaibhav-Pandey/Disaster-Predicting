import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import load_model
from tqdm import tqdm
import matplotlib.pyplot as plt

# Load the dataset
try:
    data = pd.read_csv("combined_preprocessed_earthquake_data_2014_2023.csv")
    print("Data loaded successfully.")
except FileNotFoundError:
    print("File not found. Please check the file path and name.")
    exit()
except Exception as e:
    print(f"An error occurred while loading the data: {e}")
    exit()

# Normalize the numerical features
try:
    scaler = MinMaxScaler()
    data[['latitude', 'longitude', 'depth', 'mag']] = scaler.fit_transform(data[['latitude', 'longitude', 'depth', 'mag']])
    print("Data normalization completed.")
except Exception as e:
    print(f"An error occurred during normalization: {e}")
    exit()

# Convert DataFrame to NumPy array
data_array = data[['latitude', 'longitude', 'depth', 'mag']].values

# Create sequences using vectorized operations
sequence_length = 60
num_samples = len(data_array) - sequence_length
X = np.zeros((num_samples, sequence_length, 4), dtype=np.float32)  # 4 features: latitude, longitude, depth, mag
y = np.zeros(num_samples, dtype=np.float32)

with tqdm(total=num_samples, desc="Creating sequences") as pbar:
    for i in range(num_samples):
        X[i] = data_array[i:i+sequence_length]
        y[i] = data_array[i+sequence_length, 3]  # Assume target is the 4th feature
        pbar.update(1)

# Shuffling indices
indices = np.arange(num_samples)
np.random.shuffle(indices)

# Split indices
split_idx = int(num_samples * 0.8)
train_indices = indices[:split_idx]
test_indices = indices[split_idx:]

# Use array indexing to split the data
with tqdm(total=100, desc="Splitting data into training and testing sets") as pbar:
    X_train, X_test = X[train_indices], X[test_indices]
    y_train, y_test = y[train_indices], y[test_indices]
    pbar.update(100)

print(f"Shape of X_train: {X_train.shape}")
print(f"Shape of X_test: {X_test.shape}")
print(f"Shape of y_train: {y_train.shape}")
print(f"Shape of y_test: {y_test.shape}")

# Load the trained model
try:
    model = load_model('earthquake_prediction_model.h5')
    print("Model loaded successfully.")
except Exception as e:
    print(f"An error occurred while loading the model: {e}")
    exit()

# Make predictions on the test set
predictions = model.predict(X_test)

# Print the first 10 predictions and actual values
print("Predictions vs Actual values:")
for i in range(10):
    print(f"Predicted: {predictions[i][0]}, Actual: {y_test[i]}")

# Plot the predictions vs actual values
plt.figure(figsize=(10, 6))
plt.plot(y_test[:100], label='Actual Values')
plt.plot(predictions[:100], label='Predicted Values')
plt.xlabel('Sample Index')
plt.ylabel('Magnitude')
plt.title('Predictions vs Actual Values')
plt.legend()
plt.show()

# Calculate and print evaluation metrics
mse = np.mean((predictions - y_test.reshape(-1, 1)) ** 2)
print(f'Mean Squared Error: {mse}')

mae = np.mean(np.abs(predictions - y_test.reshape(-1, 1)))
print(f'Mean Absolute Error: {mae}')
