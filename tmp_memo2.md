# 残ったメモ

タイトル案: [読書まとめ] "Hands-On..." Chapter 11: Training Deep Neural Network

* Deep Learning のチューニングを行う上で基本的な抜け漏れがないか確認したい人


## Twaeking, Dropping, or Replaceing the Upper Layers



## Model Zoos

* 画像認識用の pretrained model
* 予め学習してあるモデルやデータセットが利用できる
  * TensorFlow: https://github.com/tensorflow/models
  * Caffe: https://github.com/BVLC/caffe/wiki/Model-Zoo

## Unsupervised Pretraining

* 一部のデータにしかラベルが付いておらず、ラベルがついていないデータが大量にある場合
* 事前学習として、教師なし学習を行わせてみると効果がある
  * Autoencoder
  * Restricted Boltzmann Machine(RBM)
* 学習させる際は、一層ずつ行い、一番上の層以外はパラメータを固定させる(Frozen)
  * 例
    * 入力層 + 隠れ層1(可変) で教師なし学習
    * 入力層 + 隠れ層1(固定) + 隠れ層2(可変) で教師なし学習
    * 入力層 + 隠れ層1(固定) + 隠れ層2(固定) + 隠れ層3(可変)で教師なし学習
    * 入力層 + 隠れ層1(固定) + 隠れ層2(固定) + 隠れ層3(固定) + 出力層(可変)で **教師あり学習** (本来やりたいタスク)

<!--
できれば図を用意したい
-->

## Pretraining on an Auxiliary Task

* 補助タスクによる事前学習
  * ここで学習した低層を使いまわす
* 強化学習でよく使われているみたい？
  * 参考リンク: https://github.com/arXivTimes/arXivTimes/issues/56
* 例(画像による顔認証を行いたい場合)
  * やりたいこと: 手元のデータについて上手くクラス分類する
  * 各人について画像データが数枚しかないとする
    * 良い分類器を作るにはデータが十分でない
  * ここでネット上からランダムに顔画像を集め、
    * ２つの画像が同じ人の特徴か否か、といったタスクについて学習させる
  * ここで得た低層パラメータを使って本来やりたいことについて学習させる



## Dropout (補足)

* 提案した論文: [G. E. Hinton, 2012](https://arxiv.org/pdf/1207.0580.pdf)
* 上記のもっと詳細: [Nitish Srivastava, 2014](http://jmlr.org/papers/volume15/srivastava14a/srivastava14a.pdf)
* 元の正解率が 95% でも 1-2% 上げちゃうくらい優秀な方法
* 入力のわずかな違いに過敏にならなくなる
* 入力層と隠れ層に対して適用される(出力層には適用しません)
* 小分けにしたネットワークによるアンサンブル学習となっている

# Practical Guidelines

とりあえず事前知識が何もない場合は下記の構成を一旦試してみると良いと思います。

## とりあえず試してみるための構成

|項目|手法|
|:-------------------------|:---------------------------------|
|Initialization(初期化方法) | He initialization |
|Activation function(活性化関数) | ELU |
|Normalization(正規化)| Batch Normalization |
|Regularization| Dropout |
|Optimizer| Nesterov Accelerated Gradient(NAG) ※1 |
|Learning rate schedule | None |

* ※1: NAG は `tf.train.MomentumOptimizer()` の引数で `use_nesterov=True` を指定すると使えます
  * ただ Qiita とかだと Adam 多いし、そもそも最適化手法はたくさんあるので時間が許すなら色々試した方が良いと思います
  * 参考リンク: [深層学習の最適化アルゴリズム - Qiita](https://qiita.com/ZoneTsuyoshi/items/8ef6fa1e154d176e25b8#adasecant-2017)
* またケースによっては下記のような微調整が必要になるかもしれません

## 微調整用の項目

| ケース | 対処法 |
|:----------------------------|:-----------------|
|収束が遅すぎる、早すぎる | 学習率を上げ下げしたり、exponential decay を試してみる |
|学習データが少ない | data augmentation してみる |
| スパースなモデルが必要 | $l_1$ 正則化を加える。小さい weight を 0 にする |
| 実行時間(評価時間) を短くしたい | Batch Normalization やめる、ReLU 使う |


# 最後に

TensorFlow は僕には早すぎました

# Exercises

モチベがあれば別記事にて

# 8




```Python
he_init = tf.contrib.layers.variance_scaling_initializer()

def dnn(inputs, n_hidden_layers=5, n_neurons=100, name=None,
        activation=tf.nn.elu, initializer=he_init):
    with tf.variable_scope(name, "dnn"):
        for layer in range(n_hidden_layers):
            inputs = tf.layers.dense(inputs, n_neurons, activation=activation,
                                     kernel_initializer=initializer,
                                     name="hidden%d" % (layer + 1))
        return inputs
```

次に上記の関数を用いてモデルを構築します。

<details><summary>サンプルコード(モデル定義)</summary><div>

```Python
n_inputs = 28 * 28 # MNIST
n_outputs = 5

reset_graph()

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

dnn_outputs = dnn(X)

logits = tf.layers.dense(dnn_outputs, n_outputs, kernel_initializer=he_init, name="logits")
Y_proba = tf.nn.softmax(logits, name="Y_proba")

learning_rate = 0.01

xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
loss = tf.reduce_mean(xentropy, name="loss")

optimizer = tf.train.AdamOptimizer(learning_rate)
training_op = optimizer.minimize(loss, name="training_op")

correct = tf.nn.in_top_k(logits, y, 1)
accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")

init = tf.global_variables_initializer()
saver = tf.train.Saver()
```


</div></details>

<details><summary>サンプルコード(データ読み込み)</summary><div>

```Python
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("/tmp/data/")

X_train1 = mnist.train.images[mnist.train.labels < 5]
y_train1 = mnist.train.labels[mnist.train.labels < 5]
X_valid1 = mnist.validation.images[mnist.validation.labels < 5]
y_valid1 = mnist.validation.labels[mnist.validation.labels < 5]
X_test1 = mnist.test.images[mnist.test.labels < 5]
y_test1 = mnist.test.labels[mnist.test.labels < 5]
```



</div></details>



<details><summary>サンプルコード(学習と評価)</summary><div>

```Python

```


</div></details>

<!--
以下は Chapter 12 の内容
Title: [読書まとめ] Distributin TensorFlow Across Devices and Servers
-->


<!--
以下は Chapter 13 の内容

[読書まとめ] Chapter 13: Convolutional Neural Networks

-->


# aaa
