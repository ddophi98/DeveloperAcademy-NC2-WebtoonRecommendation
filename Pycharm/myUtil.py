import pandas as pd
import pickle as pk
from urllib import request
from PIL import Image
import os


class MyUtil:
    # 모아둔 정보로 CSV 파일 생성하기
    @staticmethod
    def make_csv(filename, ti):
        ti.to_csv(filename, encoding='utf-8-sig')

    # CSV 파일이 있다면 가져오기
    @staticmethod
    def get_from_csv(filename):
        return pd.read_csv(filename, encoding='utf-8-sig')

    # CSV 파일을 지우기
    @staticmethod
    def delete_csv(filename):
        if os.path.isfile(filename):
            os.remove(filename)

    # 특정 데이터를 파일에 저장해놓기
    @staticmethod
    def save_data(filename, data):
        with open(filename, 'wb') as f:
            pk.dump(data, f)

    # 저장해둔 데이터 불러오기
    @staticmethod
    def load_data(filename):
        with open(filename, 'rb') as f:
            return pk.load(f)

    @staticmethod
    def save_images(urls):
        if not os.path.isdir("data/images"):
            os.makedirs("data/images")
            os.makedirs("data/resized_images")
            print("--images downloading start--")
            for idx, url in enumerate(urls):
                print("\r" + str(idx + 1) + "/" + str(len(urls)), end="")
                img_name = "data/images/thumbnail" + str(idx) + ".jpg"
                resized_img_name = "data/resized_images/thumbnail" + str(idx) + ".jpeg"
                request.urlretrieve(url, img_name)
                img = Image.open(img_name).convert('RGB')
                img.save(resized_img_name, 'JPEG', qualty=85)

            print()
            print("--images downloading end--")
        else:
            print("--images already exist--")
