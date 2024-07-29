import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from tqdm import tqdm
import matplotlib.pyplot as plt
import time

# Path to your sorted combined CSV file
sorted_csv_path = 'sorted_earthquake_data_2022_2023.csv'  # Update with your actual path

# Load the sorted combined data
combined_df = pd.read_csv(sorted_csv_path, parse_dates=['time'])

# Ensure the time column is in datetime format with timezone awareness
combined_df['time'] = pd.to_datetime(combined_df['time'], utc=True, errors='coerce')

# Drop rows with invalid datetime values
combined_df = combined_df.dropna(subset=['time'])

# Remove duplicates
combined_df = combined_df.drop_duplicates()

# Display the first few rows of the sorted DataFrame
print("Sorted data:")
print(combined_df.head())

# Check for missing values
print("\nMissing values:")
print(combined_df.isnull().sum())

# Check for duplicates
print("\nNumber of duplicates:", combined_df.duplicated().sum())

# Basic statistical summary
print("\nStatistical summary:")
print(combined_df.describe())

# Define a function to preprocess data for each day
def preprocess_data(data, current_day):
    # Ensure the time column is in datetime format
    data['time'] = pd.to_datetime(data['time'], utc=True)
    
    # Filter data up to the current day
    data_up_to_now = data[data['time'] <= current_day].copy()
    
    # Feature engineering
    data_up_to_now.loc[:, 'Year'] = data_up_to_now['time'].dt.year
    data_up_to_now.loc[:, 'Month'] = data_up_to_now['time'].dt.month
    data_up_to_now.loc[:, 'Day'] = data_up_to_now['time'].dt.day
    data_up_to_now.loc[:, 'Hour'] = data_up_to_now['time'].dt.hour
    data_up_to_now.loc[:, 'Minute'] = data_up_to_now['time'].dt.minute
    data_up_to_now.loc[:, 'Second'] = data_up_to_now['time'].dt.second
    
    return data_up_to_now

# Define the date for training and validation
train_until_date = pd.Timestamp('2023-12-31', tz='UTC')
validation_start_date = pd.Timestamp('2022-01-01', tz='UTC')

# Preprocess the data up to the training date
train_data = preprocess_data(combined_df, train_until_date)

# Split data into training and validation sets
validation_data = train_data[train_data['time'] >= validation_start_date]
train_data = train_data[train_data['time'] < validation_start_date]

# Define features and target
features = ['latitude', 'longitude', 'depth', 'Year', 'Month', 'Day', 'Hour', 'Minute', 'Second']
target = 'mag'

# Split validation data into features (X_val) and target (y_val)
X_val = validation_data[features]
y_val = validation_data[target]

# Initialize the model
model = RandomForestRegressor(n_estimators=100, random_state=42)

# Initialize tqdm progress bar and lists to store RMSE values
progress_bar = tqdm(total=len(train_data), desc="Training Progress")
rmse_list = []
train_sizes = []

# Train the model incrementally
print("Training the model incrementally...")
start_time = time.time()
for i in range(1, len(train_data) + 1):
    incremental_train_data = train_data.iloc[:i]
    X_train = incremental_train_data[features]
    y_train = incremental_train_data[target]
    
    model.fit(X_train, y_train)
    
    # Evaluate the model on the validation set
    y_pred = model.predict(X_val)
    rmse = np.sqrt(mean_squared_error(y_val, y_pred))
    rmse_list.append(rmse)
    train_sizes.append(i)
    
    progress_bar.update(1)
end_time = time.time()
progress_bar.close()
print(f"Incremental training completed. Total time: {end_time - start_time:.2f} seconds")

# Plot RMSE over time
plt.figure(figsize=(10, 6))
plt.plot(train_sizes, rmse_list, marker='o')
plt.xlabel('Number of Training Samples')
plt.ylabel('RMSE')
plt.title('RMSE Over Time')
plt.show()
