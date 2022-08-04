import tensorflow as tf
import matplotlib.pyplot as plt


class MyStyleExtract:

    def __init__(self):
        self.max_dim = 512  # 이미지 크기를 512 픽셀로 제한

    # 이미지 불러오기
    def load_img(self, img_url):
        img = tf.io.read_file(img_url)
        img = tf.image.decode_image(img, channels=3)
        img = tf.image.convert_image_dtype(img, tf.float32)

        shape = tf.cast(tf.shape(img)[:-1], tf.float32)
        long_dim = max(shape)
        scale = self.max_dim / long_dim

        new_shape = tf.cast(shape * scale, tf.int32)

        img = tf.image.resize(img, new_shape)
        img = img[tf.newaxis, :]

        return img

    # 이미지 보여주기
    def img_show(self, image, title=None):
        if len(image.shape) > 3:
            image = tf.squeeze(image, axis=0)

        plt.imshow(image)
        plt.figure(figsize=(8, 8))
        if title:
            plt.title(title)

