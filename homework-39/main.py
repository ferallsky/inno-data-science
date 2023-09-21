import json
from pandas import json_normalize
from classes import Settings, StudentRepository, ModelService
from flask import Flask, request, jsonify

app = Flask(__name__)
settings = Settings()


# Метод для классификации новой квартиры
@app.route('/classifyStudent', methods=['POST'])
def classify():
    try:
        data = json_normalize(request.json.get('data'))
        model = ModelService.load_model(settings.model_path())
        predicted = model.predict(data)[0][0]

        return f"Студент скорее всего получит: {settings.final_result_list[predicted]}"
    except Exception as e:
        return jsonify({'error': str(e)})


@app.route('/train', methods=['GET'])
def train():
    try:
        df_repo = StudentRepository(settings)
        df = df_repo.loadOrCreate()
        X_train, X_test, y_train, y_test = ModelService.preprocess_dataset(df, need_best_features=False)
        ModelService.train_model(X_train, y_train, file_to_save=settings.model_path())
        return jsonify({'message': 'model saved'})
    except Exception as e:
        return jsonify({'error': str(e)})


if __name__ == '__main__':
    app.run(debug=True)
