import PIL
import tensorflow as tf
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib.pyplot as plt

class MyStyleClustering:
    max_dim = 150
    min_dim = 100
    content_layers = ['block5_conv2']
    style_layers = ['block1_conv1',
                    'block2_conv1',
                    'block3_conv1',
                    'block4_conv1',
                    'block5_conv1']

    def __init__(self, data):
        self.data = data
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

    # 학습을 시키면서 스타일 추출해내기
    def test_extract_style(self, style_image, train_n):
        content_image = np.ones((1, 100, 100, 3))

        extractor = StyleContentModel(self.style_layers, self.content_layers)
        style_targets = extractor.call(style_image)['style']
        content_targets = extractor.call(content_image)['content']

        image = tf.Variable(content_image)

        opt = tf.optimizers.Adam(learning_rate=0.02, beta_1=0.99, epsilon=1e-1)

        squeezed_img = np.array(content_image).squeeze()
        plt.subplot(2, 3, 1)
        plt.imshow(squeezed_img)
        plt.title("Before")

        squeezed_img = np.array(style_image).squeeze()
        plt.subplot(2, 3, 3)
        plt.imshow(squeezed_img)
        plt.title("Before")

        for step in range(train_n):
            print("\r" + str(step + 1) + "/" + str(train_n), end="")
            self.train_step(image=image,
                            style_targets=style_targets,
                            content_targets=content_targets,
                            opt=opt,
                            extractor=extractor)

        result_image = np.array(image).squeeze()
        plt.subplot(2, 3, 5)
        plt.imshow(result_image)
        plt.title("After")

        plt.show()


    # 학습을 시키면서 스타일 추출해내기
    def extract_style(self, images, train_n):
        trained_images = []
        tf_var = tf.Variable(images[0][:, :self.min_dim, :self.min_dim, :])
        extractor = StyleContentModel()
        opt = tf.optimizers.Adam(learning_rate=0.02, beta_1=0.99, epsilon=1e-1)

        for i, img in enumerate(images):

            print("\r" + str(i + 1) + "/" + str(len(images)), end="")
            cropped_img = img[:, :self.min_dim, :self.min_dim, :]

            style_targets = extractor.call(cropped_img)
            tf_var.assign(cropped_img)

            for step in range(train_n):
                self.train_step(style_targets=style_targets,
                                opt=opt,
                                extractor=extractor,
                                image=tf_var)

            result_image = np.array(tf_var)
            result_image = result_image.reshape(-1)
            trained_images.append(result_image)

        return trained_images

    def svd(self, trained_images, svd_n):
        print()
        if svd_n == 0:
            self.style_info_list = trained_images
        else:
            svd = TruncatedSVD(n_components=svd_n)
            self.style_info_list = np.array(svd.fit_transform(trained_images))

    # 스타일 학습시킬 때 쓸 loss 함수
    def style_content_loss(self, outputs, style_targets, content_targets):
        style_weight = 1e4
        content_weight = 1e-2

        style_outputs = outputs['style']
        content_outputs = outputs['content']
        style_loss = tf.add_n([tf.reduce_mean((style_outputs[name] - style_targets[name]) ** 2)
                               for name in style_outputs.keys()])
        style_loss *= style_weight / len(self.style_layers)

        content_loss = tf.add_n([tf.reduce_mean((content_outputs[name] - content_targets[name]) ** 2)
                                 for name in content_outputs.keys()])
        content_loss *= content_weight / len(self.content_layers)
        loss = style_loss + content_loss
        return loss

    # 픽셀 값이 실수이므로 0과 1 사이의 값으로 바꾸기
    def clip_0_1(self, image):
        return tf.clip_by_value(image, clip_value_min=0.0, clip_value_max=1.0)

    # 학습하기
    @tf.function()
    def train_step(self, image, style_targets, content_targets, opt, extractor):
        with tf.GradientTape() as tape:
            outputs = extractor(image)
            loss = self.style_content_loss(outputs=outputs,
                                           style_targets=style_targets,
                                           content_targets=content_targets)


        grad = tape.gradient(loss, image)
        opt.apply_gradients([(grad, image)])
        image.assign(self.clip_0_1(image))

    # tensor 자료형을 이미지로 변환해주기
    def tensor_to_image(self, tensor):
        tensor = tensor * 255
        tensor = np.array(tensor, dtype=np.uint8)
        if np.ndim(tensor) > 3:
            assert tensor.shape[0] == 1
            tensor = tensor[0]
        return PIL.Image.fromarray(tensor)

    # 이미지 plt로 보여주기
    def imshow(self, image, title=None):
        # self.tensor_to_image(result_image)
        # plt.subplot(1, 2, 2)
        # self.imshow(result_image, "After")
        # plt.show()
        if len(image.shape) > 3:
            image = tf.squeeze(image, axis=0)

        plt.imshow(image)
        if title:
            plt.title(title)

    # k-means 클러스터링 하기
    def kmeans_cluster(self, k):
        kmeans = KMeans(n_clusters=k)
        pred = kmeans.fit_predict(self.style_info_list)
        return pred

    # 클러스터링 결과 그래프로 보여주기
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
    def compare_similarity(self, idx, row):
        self.data = self.data.sort_index()

        # 해당 행의 웹툰이 어느 클러스터에 속해있고 인덱스는 몇인지 구하기
        target_cluster = row["cluster_style"]
        target_webtoon_idx = idx

        # 해당 클러스트 안에 있는 웹툰들을 모두 구하기
        webtoons_in_target_cluster = self.data[self.data["cluster_style"] == target_cluster]

        webtoons_idx = webtoons_in_target_cluster.index

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

        # 높은 유사도 순으로 웹툰 인덱스 반환 (0인 것은 뺌)
        return list(webtoons_idx[sorted_idx[:len([x for x in sorted_sim_values if x != 0])]])

# 스타일 추출하는 모델 정의하기
class StyleContentModel(tf.keras.models.Model):
    def __init__(self, style_layers, content_layers):
        super(StyleContentModel, self).__init__()
        self.vgg = self.vgg_layers(style_layers + content_layers)
        self.style_layers = style_layers
        self.content_layers = content_layers
        self.num_style_layers = len(style_layers)
        self.vgg.trainable = False

    # vgg 모델 불러오기
    def vgg_layers(self, layer_names):
        # 이미지넷 데이터셋에 사전학습된 VGG 모델 불러오기
        vgg = tf.keras.applications.VGG19(include_top=False, weights='imagenet')
        vgg.trainable = False

        outputs = [vgg.get_layer(name).output for name in layer_names]

        model = tf.keras.Model([vgg.input], outputs)
        return model

    # 스타일을 뽑아내기 위한 그람 행렬
    def gram_matrix(self, input_tensor):
        result = tf.linalg.einsum('bijc,bijd->bcd', input_tensor, input_tensor)
        input_shape = tf.shape(input_tensor)
        num_locations = tf.cast(input_shape[1] * input_shape[2], tf.float32)
        return result / num_locations

    def call(self, inputs):
        # "[0,1] 사이의 실수 값을 입력으로 받습니다"
        inputs = inputs * 255.0
        preprocessed_input = tf.keras.applications.vgg19.preprocess_input(inputs)
        outputs = self.vgg(preprocessed_input)
        style_outputs, content_outputs = (outputs[:self.num_style_layers],
                                          outputs[self.num_style_layers:])

        style_outputs = [self.gram_matrix(style_output)
                         for style_output in style_outputs]

        content_dict = {content_name: value
                        for content_name, value
                        in zip(self.content_layers, content_outputs)}

        style_dict = {style_name: value
                      for style_name, value
                      in zip(self.style_layers, style_outputs)}

        return {'content': content_dict, 'style': style_dict}