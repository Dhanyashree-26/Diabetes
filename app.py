from flask import Flask, request, jsonify
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler

app = Flask(__name__)

# Load and prepare your data
data = pd.read_csv(r'C:\Users\dhanyashree\OneDrive\Desktop\diabetes.csv')
X = data[['Age', 'BloodPressure', 'BMI', 'Glucose']]
y = data['Outcome']

# Fill missing values
X['BloodPressure'] = X['BloodPressure'].fillna(X['BloodPressure'].mean())
X['Glucose'] = X['Glucose'].fillna(X['Glucose'].mean())

# Split and scale the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train the model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train_scaled, y_train)

# Define the prediction route
@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()  # Get JSON data from the request
    age = data['age']
    bmi = data['bmi']
    systolic = data['systolic']
    diastolic = data['diastolic']
    glucose = data['glucose']

    # Prepare the input for prediction
    new_data = [[age, systolic, bmi, glucose]]  # Add diastolic if required by model

    # Scale the new data
    new_data_scaled = scaler.transform(new_data)

    # Make prediction
    predicted_disease = model.predict(new_data_scaled)
    probability_disease = model.predict_proba(new_data_scaled)[0][1] * 100

    return jsonify({
        "prediction": "Diabetes" if predicted_disease[0] else "No Diabetes",
        "probability": probability_disease
    })

if __name__ == '__main__':
    app.run(debug=True)
