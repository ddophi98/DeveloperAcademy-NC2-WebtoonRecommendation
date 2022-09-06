from konlpy.tag import Kkma
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD

class MyTokenize:
    pos = ("N", "V", "M", "XR")  # 토큰화할 단어 태그 http://kkma.snu.ac.kr/documents/?doc=postag

    def __init__(self, data):
        self.tfidf_vectorizer = TfidfVectorizer(
            tokenizer=self.tokenizer,  # 문장에 대한 tokenizer (위에 정의한 함수 이용)
            min_df=1,  # 단어가 출현하는 최소 문서의 개수
            sublinear_tf=True  # tf값에 1+log(tf)를 적용하여 tf값이 무한정 커지는 것을 막음
        )
        self.story_data = data['story']

    # 토큰화하기
    def tokenizer(self, raw_texts):
        kkma = Kkma()
        p = kkma.pos(raw_texts)
        o = [word for word, tag in p if (len(word) > 1) and (tag.startswith(self.pos))]
        return o

    # 토큰화 결과 확인해보기
    def print_tokenize_result(self):
        tokenized_sentence = []
        for i, story in enumerate(self.story_data):
            tokenized_sentence.append(self.tokenizer(story))
            print(str(i+1) + " / " + str(len(self.story_data)))
            print(story)
            print(tokenized_sentence[-1])
            print("------------------------------------------------------------")

    # 토근화를 기반으로 벡터화하고 데이터 반환하기
    def get_vectorized_data(self):
        vectorized = self.tfidf_vectorizer.fit_transform(self.story_data)
        return vectorized
