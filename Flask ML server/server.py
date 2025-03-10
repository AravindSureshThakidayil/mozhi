# Importing Necessary modules
import copy
import itertools
import string
from typing import Annotated

import cv2
import mediapipe as mp
import numpy as np
import pandas as pd
from fastapi import FastAPI
import uvicorn
from tensorflow import keras
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel
import base64
# Blob URL


def process_image(image):

# Load the saved model
    try:
        model = keras.models.load_model("model2.h5")
    except Exception as e:
        print("Error loading model:", e)
        exit()

    mp_drawing = mp.solutions.drawing_utils
    mp_drawing_styles = mp.solutions.drawing_styles
    mp_hands = mp.solutions.hands

    # Define gesture labels (digits + alphabets)
    alphabet = ['1', '2', '3', '4', '5', '6', '7', '8', '9'] + list(string.ascii_uppercase)

    # Function to extract landmarks (x, y) from a hand
    def calc_landmark_list(image, hand_landmarks):
        image_width, image_height = image.shape[1], image.shape[0]
        landmark_point = []

        for landmark in hand_landmarks.landmark:
            landmark_x = min(int(landmark.x * image_width), image_width - 1)
            landmark_y = min(int(landmark.y * image_height), image_height - 1)
            landmark_point.append([landmark_x, landmark_y])

        return landmark_point

    # Function to process landmarks and normalize
    def pre_process_landmark(landmark_list_left, landmark_list_right):
        temp_landmark_list_left = copy.deepcopy(landmark_list_left)
        temp_landmark_list_right = copy.deepcopy(landmark_list_right)

        # Convert to relative coordinates (Left Hand)
        if temp_landmark_list_left:
            base_x, base_y = temp_landmark_list_left[0]
            for i in range(len(temp_landmark_list_left)):
                temp_landmark_list_left[i][0] -= base_x
                temp_landmark_list_left[i][1] -= base_y
        else:
            temp_landmark_list_left = [[0, 0]] * 21  # Fill with zeros if no left hand detected

        # Convert to relative coordinates (Right Hand)
        if temp_landmark_list_right:
            base_x, base_y = temp_landmark_list_right[0]
            for i in range(len(temp_landmark_list_right)):
                temp_landmark_list_right[i][0] -= base_x
                temp_landmark_list_right[i][1] -= base_y
        else:
            temp_landmark_list_right = [[0, 0]] * 21  # Fill with zeros if no right hand detected

        # Flatten (42 features per hand)
        temp_landmark_list_left = list(itertools.chain.from_iterable(temp_landmark_list_left))
        temp_landmark_list_right = list(itertools.chain.from_iterable(temp_landmark_list_right))

        # Combine both hands (42 left + 42 right = 84 features)
        combined_landmarks = temp_landmark_list_left + temp_landmark_list_right

        # Normalize
        max_value = max(map(abs, combined_landmarks)) if any(combined_landmarks) else 1  # Avoid zero max_value
        combined_landmarks = [x / max_value for x in combined_landmarks]

        return combined_landmarks
    # Initialize webcam
   

    with mp_hands.Hands(
        model_complexity=0,
        max_num_hands=2,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5) as hands:
            #image = cv2.flip(image, 1)
            image.flags.writeable = False
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = hands.process(image)

            image.flags.writeable = True
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
            debug_image = copy.deepcopy(image)

            # Process hand landmarks
            landmark_list_left, landmark_list_right = [], []

            if results.multi_hand_landmarks:
                if len(results.multi_hand_landmarks) == 1:
                    landmark_list_right = calc_landmark_list(debug_image, results.multi_hand_landmarks[0])
                elif len(results.multi_hand_landmarks) == 2:
                    landmark_list_left = calc_landmark_list(debug_image, results.multi_hand_landmarks[0])
                    landmark_list_right = calc_landmark_list(debug_image, results.multi_hand_landmarks[1])

            pre_processed_landmark_list = pre_process_landmark(landmark_list_left, landmark_list_right)

            # Ensure correct shape for model prediction
            df = pd.DataFrame([pre_processed_landmark_list])

            try:
                predictions = model.predict(df, verbose=0)
                predicted_class = np.argmax(predictions, axis=1)[0]

                if predicted_class < len(alphabet):
                    label = alphabet[predicted_class]
                    cv2.putText(image, label, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 
                                1.5, (0, 0, 255), 2)
                    print(label)
                    return label

                    print("------------------------")
                else:
                    print("Warning: Predicted class out of range.")

            except Exception as e:
                print("Error during prediction:", e)
                return None

                # Draw hand landmarks
                


class Item(BaseModel):
     imagedata: str



origin=['*']
# Declaring our FastAPI instance
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origin,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Defining path operation for root endpoint
@app.get('/')
def main():
	return {'message': 'Welcome to GeeksforGeeks!'}

# Defining path operation for /name endpoint
@app.get('/{name}')
def hello_name(name : str): 
	# Defining a function that takes only string as input and output the
	# following message. 
	return {'message': f'Welcome to GeeksforGeeks!, {name}'}

@app.post('/predict')
async def predict(item: Item):

      try:
             img_bytes=base64.b64decode(item.imagedata)
             image = np.frombuffer(img_bytes, dtype=np.uint8)
             with open("image.png", "wb") as f:
                f.write(image)  
                image = cv2.imread("image.png")
                predicted=process_image(image)
             return {"message":"success","predicted":predicted}
      except Exception as e:
            raise e
      

          
    

    
