import tensorflow as tf
import numpy as np
from sklearn.cluster import KMeans
from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

class MyStyleClustering:
    max_dim = 32

    def __init__(self, data, k):
        self.data = data
        self.k = k
        self.style_info_list = np.array([])

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
        images_size = len(images)
        infos = []
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
            infos.append(style_info)
        print()
        svd = TruncatedSVD(n_components=2)
        self.style_info_list = np.array(svd.fit_transform(infos))

    def kmeans_cluster(self):
        kmeans = KMeans(n_clusters=self.k)
        pred = kmeans.fit_predict(self.style_info_list)
        return pred

    def print_cluster_details(self, pred):
        labels = pred.tolist()
        for num in range(self.k):
            titles = [self.data['title'].tolist()[idx] for idx, label in enumerate(labels) if label == num]
            print("label: " + str(num))
            print(titles)
            print()

    def visualize(self, cluster_labels):
        fig = plt.figure(figsize=(6,4))
        colors = plt.cm.get_cmap("Spectral")(np.linspace(0, 1, len(set(cluster_labels))))
        ax = fig.add_subplot(1, 1, 1)

        for k, col in zip(range(len(colors)), colors):
            my_members = (cluster_labels == k)
            ax.plot(
                self.style_info_list[my_members, 0],
                self.style_info_list[my_members, 1],
                'w',
                markerfacecolor=col,
                marker='.'
            )
        ax.set_title('K-Means')

        plt.show()

    # 유사도 그래프로 비교해보기
    def compare_similarity(self, item_title):
        self.data = self.data.sort_index()

        # 해당 제목을 가진 웹툰이 어느 클러스터에 속해있고 인덱스는 몇인지 구하기
        target_cluster = 0
        target_webtoon_idx = 0

        for idx, row in self.data.iterrows():
            if row['title'] == item_title:
                target_cluster = row["cluster_style"]
                target_webtoon_idx = idx
                break
        print("타겟 클러스터 번호:", target_cluster)
        print("타겟 웹툰 인덱스:", target_webtoon_idx)

        # 해당 클러스트 안에 있는 웹툰들을 모두 구하기
        webtoons_in_target_cluster = self.data[self.data["cluster_style"] == target_cluster]

        webtoons_idx = webtoons_in_target_cluster.index
        print("유사도 비교 기준 웹툰:", item_title)
        print("유사한 웹툰 인덱스:")
        print(list(webtoons_idx))

        # 위에서 추출한 카테고리로 클러스터링된 문서들의 인덱스 중 비교기준문서를 제외한 다른 문서들과의 유사도 측정
        similarity = cosine_similarity(self.style_info_list[target_webtoon_idx].reshape(1, -1), self.style_info_list[webtoons_idx])

        # array 내림차순으로 정렬한 후 인덱스 반환
        sorted_idx = np.argsort(similarity)[:, ::-1]
        # 비교문서 당사자는 제외한 인덱스 추출 (내림차순 정렬했기때문에 0번째가 무조건 가장 큰 값임)
        sorted_idx = sorted_idx[:, 1:]

        # index로 넣으려면 1차원으로 reshape해주기
        sorted_idx = sorted_idx.reshape(-1)

        # 앞에서 구한 인덱스로 유사도 행렬값도 정렬
        sorted_sim_values = similarity.reshape(-1)[sorted_idx]
        print("유사도(내림차순 정렬):")
        print(sorted_sim_values)
        print()

        # 그래프 생성
        selected_sim_df = pd.DataFrame()
        selected_sim_df['title'] = webtoons_in_target_cluster.iloc[sorted_idx]['title']
        selected_sim_df['similarity'] = sorted_sim_values

        plt.figure(figsize=(25, 10), dpi=60)
        sns.barplot(data=selected_sim_df, x='similarity', y='title')
        plt.title(item_title)
        plt.show()

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