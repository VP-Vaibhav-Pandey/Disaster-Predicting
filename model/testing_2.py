import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from tqdm import tqdm
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

# Define the date for training and prediction
train_until_date = pd.Timestamp('2023-12-31', tz='UTC')

# Preprocess the data up to the training date
train_data = preprocess_data(combined_df, train_until_date)

# Define features and target
features = ['latitude', 'longitude', 'depth', 'Year', 'Month', 'Day', 'Hour', 'Minute', 'Second']
target = 'mag'

# Split data into features (X) and target (y)
X_train = train_data[features]
y_train = train_data[target]

# Initialize the model
model = RandomForestRegressor(n_estimators=100, random_state=42)

# Initialize tqdm progress bar
progress_bar = tqdm(total=model.n_estimators, desc="Training Progress")

# Train the model with timing
print("Training the model...")
start_time = time.time()
model.fit(X_train, y_train)
end_time = time.time()
progress_bar.update(model.n_estimators)
progress_bar.close()
print(f"Model trained on data up to 2023-12-31. Training time: {end_time - start_time:.2f} seconds")

# Define the next day for prediction
next_day = train_until_date + pd.Timedelta(days=1)

# Create a sample DataFrame for the next day with similar structure
# Assuming we predict for the same location, depth, etc., from the last available data
# You might want to create more realistic sample data for the next day
next_day_data = combined_df.tail(1).copy()
next_day_data['time'] = next_day
next_day_data.loc[:, 'Year'] = next_day.year
next_day_data.loc[:, 'Month'] = next_day.month
next_day_data.loc[:, 'Day'] = next_day.day
next_day_data.loc[:, 'Hour'] = 0
next_day_data.loc[:, 'Minute'] = 0
next_day_data.loc[:, 'Second'] = 0

X_next_day = next_day_data[features]

# Make predictions for the next day
predictions = model.predict(X_next_day)

# Display the predictions
print(f"Predicted magnitudes for {next_day.date()}: {predictions}")

# Optional: If you have real data for the next day to compare, you could evaluate it here
# y_next_day_actual = ...  # Load the actual data if available
# mse = mean_squared_error(y_next_day_actual, predictions)
# rmse = np.sqrt(mse)
# print(f"RMSE for {next_day.date()}: {rmse}")
