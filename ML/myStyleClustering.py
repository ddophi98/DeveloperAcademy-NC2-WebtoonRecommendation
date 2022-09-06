import tensorflow as tf
import numpy as np
from sklearn.cluster import KMeans

class MyStyleClustering:
    max_dim = 32

    def __init__(self, data):
        self.data = data

    # 이미지 크기 바꾸기
    def resize_img(self, path_to_img):
        img = tf.io.read_file(path_to_img)
        img = tf.image.decode_image(img, channels=3)
        img = tf.image.convert_image_dtype(img, tf.float32)
        img = np.squeeze(img)

        shape = tf.cast(tf.shape(img)[:-1], tf.float32)
        long_dim = max(shape)
        scale = self.max_dim / long_dim

        new_shape = tf.cast(shape * scale, tf.int32)
        img = tf.image.resize(img, new_shape)
        img = img[tf.newaxis, :]
        return img

    # url 로부터 이미지 가져오기
    def get_img(self):
        images = []
        thumbnails_size = len(self.data['thumbnail'])
        for i, thumbnail in enumerate(self.data['thumbnail']):
            print("\r" + str(i + 1) + "/" + str(thumbnails_size), end="")
            img = tf.keras.utils.get_file('thumbnail' + str(i + 1) + '.jpg', thumbnail)
            images.append(self.resize_img(img))
        print()
        return images

    def extract_style(self, images):
        extractor = StyleContentModel()

        # 스타일 추출한 후 클러스터링을 위해 차원 축소하기
        style_info_list = []
        images_size = len(images)
        for i, img in enumerate(images):
            print("\r" + str(i + 1) + "/" + str(images_size), end="")
            result = extractor.call(img)

            # 한 썸네일에서 나온 각 층의 정보들을 합쳐놓기
            style_info = []
            for output in result:
                layer_info = output.numpy().reshape(-1)
                style_info.append(layer_info)
            style_info = np.concatenate(style_info)

            # 모든 썸네일에서 나온 정보들을 한 배열에 저장해놓기
            style_info_list.append(style_info)
        print()
        return style_info_list

    def kmeans_cluster(self, style_info_list, k=10):
        kmeans = KMeans(n_clusters=k)
        pred = kmeans.fit_predict(style_info_list)
        return pred

    def print_cluster_details(self, pred):
        labels = pred.tolist()
        for num in range(10):
            titles = [self.data['title'].tolist()[idx] for idx, label in enumerate(labels) if label == num]
            print("label: " + str(num))
            print(titles)
            print()

# 스타일 추출하는 모델 정의하기
class StyleContentModel(tf.keras.models.Model):
    style_layers = ['block1_conv1', 'block2_conv1', 'block3_conv1', 'block4_conv1', 'block5_conv1']

    def __init__(self):
        super(StyleContentModel, self).__init__()
        self.vgg = self.vgg_layers()
        self.vgg.trainable = False

    # vgg 모델 불러오기
    def vgg_layers(self):
        # 이미지넷 데이터셋에 사전학습된 VGG 모델 불러오기
        vgg = tf.keras.applications.VGG19(include_top=False, weights='imagenet')
        vgg.trainable = False

        # 중간층의 출력값을 배열로 반환하기
        outputs = [vgg.get_layer(name).output for name in self.style_layers]
        model = tf.keras.Model([vgg.input], outputs)
        return model

    # 스타일을 뽑아내기 위한 그람 행렬
    def gram_matrix(self, input_tensor):
        result = tf.linalg.einsum('bijc,bijd->bcd', input_tensor, input_tensor)
        input_shape = tf.shape(input_tensor)
        num_locations = tf.cast(input_shape[1] * input_shape[2], tf.float32)
        return result / num_locations

    def call(self, inputs):
        inputs = inputs * 255.0
        preprocessed_input = tf.keras.applications.vgg19.preprocess_input(inputs)
        style_outputs = self.vgg(preprocessed_input)
        style_outputs = [self.gram_matrix(style_output) for style_output in style_outputs]

        return style_outputs