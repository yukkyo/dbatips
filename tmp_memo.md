<!--
この記事では類似したコードが何度も出てきます。DRY とか知りません。
その代わり、この記事を読み終える頃にはそこらの TensorFlow のコードを見ても「もう見た」って気持ちを持てるはずです。
-->

# Reusing Models from Other Frameworks

ここでは他のフレームワーク(自作含む)で求めたパラメータで Tensorflow のネットワークを構築する方法を紹介します。
(互換性のあるフレームワークなら用意してある関数使ったほうが良いと思います)

今回は互換性が全くない状態を想定します。
事前に以下のようにして他のフレームワーク等からパラメータを抽出してある状態を想定しています。


<details><summary>共通部分</summary><div>

```Python
reset_graph()

n_inputs = 2
n_hidden1 = 3

original_w = [[1., 2., 3.], [4., 5., 6.]]  # weight, 他のフレームワークから持ってきたパラメータ
original_b = [7., 8., 9.]                  # bias, 他のフレームワークから持ってきたパラメータ

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu, name="hidden1")
# [...] 以下に自分で組んだ他の層が定義されているとする
```

</div></details>


上記で組んだモデル内の隠れ層1のパラメータに `original_w` と `original_b` を適用します。


## (比較的)簡潔な方法

ここでの "kernel" は "weights" のことを指しています。
おおまかな流れは以下の通りです。

* `graph.get_operation_by_name` で該当の層の kernel(weights) や bias の Operation オブジェクトをとってくる
* 各 Operation オブジェクトへの入力となる Tensor オブジェクト(の参照？) を `init_kernel` と `init_bias` に渡す(参照を渡してる？)
* `sess.run()` 実行時に `feed_dict` でそれぞれの値(`original_w` と `original_b`)を渡す

<details><summary>サンプルコード</summary><div>

```Python
# Get a handle on the assignment nodes for the hidden1 variables
graph = tf.get_default_graph()
assign_kernel = graph.get_operation_by_name("hidden1/kernel/Assign")
assign_bias = graph.get_operation_by_name("hidden1/bias/Assign")
init_kernel = assign_kernel.inputs[1]
init_bias = assign_bias.inputs[1]

init = tf.global_variables_initializer()

with tf.Session() as sess:
    sess.run(init, feed_dict={init_kernel: original_w, init_bias: original_b})
    # [...] 学習開始
    # 以下は確認用サンプル
    print(hidden1.eval(feed_dict={X: [[10.0, 11.0]]}))  # not shown in the book
    # => [[  61.   83.  105.]]
```

</div></details>

## (比較的)冗長だが、明示的な方法

個人的にはこちらの方が明示してて分かりやすいですが、`variable` の定義や `placeholder` で型やサイズ(shape)を与える必要があるので冗長でやや効率が悪いとのことです(実行のパフォーマンスについてはわかってません…)。

おおまかな流れは以下の通りです。

* `variable` を定義
* 実行時の引数として `placeholder` を定義
* `tf.assign` で `varieble` に `placeholder` を割り当て
* `sess.run()` 実行時に `feed_dict` でそれぞれの値 (`original_w` と `original_b`) を渡す


<details><summary>サンプルコード</summary><div>

```Python
# Get a handle on the variables of layer hidden1
with tf.variable_scope("", default_name="", reuse=True):  # root scope
    hidden1_weights = tf.get_variable("hidden1/kernel")
    hidden1_biases = tf.get_variable("hidden1/bias")

# Create dedicated placeholders and assignment nodes
original_weights = tf.placeholder(tf.float32, shape=(n_inputs, n_hidden1))
original_biases = tf.placeholder(tf.float32, shape=n_hidden1)
assign_hidden1_weights = tf.assign(hidden1_weights, original_weights)
assign_hidden1_biases = tf.assign(hidden1_biases, original_biases)

init = tf.global_variables_initializer()

with tf.Session() as sess:
    sess.run(init)
    sess.run(assign_hidden1_weights, feed_dict={original_weights: original_w})
    sess.run(assign_hidden1_biases, feed_dict={original_biases: original_b})
    # [...] Train the model on your new task
    print(hidden1.eval(feed_dict={X: [[10.0, 11.0]]}))
```

</div></details>

# Freezing the Lower Layers

ここまでで事前に学習した層を再利用できるようになりましたが、
上記の方法だと再利用した層のパラメータ(重みやバイアス等)も更新されます。
ここでは再利用した低層のパラメータを固定したまま学習させてみます。

固定させることで以下のようなメリットがあります。

* 低層のパラメータを更新する必要がないので学習が速くなる
* 後何か（あれば

また、ある層から下のパラメータを固定する方法は以下の2通りあります。
まだ使い分けるシチュエーションを知らないのですが、後者の方がモデル定義の時点で分かるので他の人が読んだときに意図が伝わりやすい気がします。


* `optimizer.minimize()` の引数 `var_list` で学習する変数を指定
* ネットワークの定義時に `tf.stop_gradient()` による層を挿入する

また事前に以下の共通部分は実行してあるとします。
今回は入力層、出力層、隠れ層4つからなるネットワークを構築します。
以下のように層によってパラメータの扱いが違うことに注意してください。

* 隠れ層 1,2 は他のモデルのパラメータを再利用し、かつパラメータを **更新しない**
* 隠れ層 3 は他のモデルのパラメータを再利用し、かつパラメータを **更新する**
* 隠れ層 4 と出力層は新しくパラメータを学習する

<details><summary>共通部分(各サンプルコードの前にそれぞれ実行する)</summary><div>

```Python
reset_graph()

n_inputs = 28 * 28  # MNIST
n_hidden1 = 300 # 他のモデルのパラメータを再利用する。パラメータは更新しない
n_hidden2 = 50  # 他のモデルのパラメータを再利用する。パラメータは更新しない
n_hidden3 = 50  # 他のモデルのパラメータを再利用する。パラメータは "更新する"
n_hidden4 = 20  # 新しく学習する
n_outputs = 10  # 新しく学習する

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")
```

</div></details>
<br>

## `optimizer.minimize()` の引数 `var_list` で学習する変数を指定

ポイントは以下2点

* `tf.get_collection()` で学習(更新)対象となる層のパラメータ名一覧を取得
* `optimizer.minimize()` の引数 `var_list` で上記のパラメータを指定

<details><summary>サンプルコード(事前に一度共通部分を実行する)</summary><div>

```Python
with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu, name="hidden1")       # reused
    hidden2 = tf.layers.dense(hidden1, n_hidden2, activation=tf.nn.relu, name="hidden2") # reused
    hidden3 = tf.layers.dense(hidden2, n_hidden3, activation=tf.nn.relu, name="hidden3") # reused
    hidden4 = tf.layers.dense(hidden3, n_hidden4, activation=tf.nn.relu, name="hidden4") # new!
    logits = tf.layers.dense(hidden4, n_outputs, name="outputs")                         # new!

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
    loss = tf.reduce_mean(xentropy, name="loss")

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")

with tf.name_scope("train"):
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    # ここで学習対象の変数名一覧を取得
    # scope は正規表現で指定可能
    train_vars = tf.get_collection(tf.GraphKeys.TRAINABLE_VARIABLES,
                                   scope="hidden[34]|outputs")
    # ここで更新対象パラメータを指定
    training_op = optimizer.minimize(loss, var_list=train_vars)

# 実行前初期化
init = tf.global_variables_initializer()
new_saver = tf.train.Saver()

# 隠れ層1 から 3 のパラメータを再利用するために事前定義
# まだチェックポイントを特定していないことに注意
reuse_vars = tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES,
                               scope="hidden[123]") # regular expression
reuse_vars_dict = dict([(var.op.name, var) for var in reuse_vars])
restore_saver = tf.train.Saver(reuse_vars_dict) # to restore layers 1-3

init = tf.global_variables_initializer()
saver = tf.train.Saver()

with tf.Session() as sess:
    init.run()
    # どこかで学習させてチェックポイント './my_model_final.ckpt' に保存済だとする
    # 隠れ層1から3のパラメータを指定
    restore_saver.restore(sess, "./my_model_final.ckpt")

    for epoch in range(n_epochs):
        for iteration in range(mnist.train.num_examples // batch_size):
            X_batch, y_batch = mnist.train.next_batch(batch_size)
            sess.run(training_op, feed_dict={X: X_batch, y: y_batch})
        accuracy_val = accuracy.eval(feed_dict={X: mnist.test.images,
                                                y: mnist.test.labels})
        print(epoch, "Test accuracy:", accuracy_val)

    save_path = saver.save(sess, "./my_new_model_final.ckpt")
```

</div></details>
<br>

## ネットワークの定義時に `tf.stop_gradient()` による層を挿入する

* `tf.stop_gradient(hidden2)` により勾配計算を途中でやめるための層が追加されている

<details><summary>サンプルコード(事前に共通部分を一度実行する)</summary><div>

```Python
with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu,
                              name="hidden1") # reused frozen
    hidden2 = tf.layers.dense(hidden1, n_hidden2, activation=tf.nn.relu,
                              name="hidden2") # reused frozen
    hidden2_stop = tf.stop_gradient(hidden2)  # ここから上の勾配計算をやめる(≒ パラメータ更新をしない？)
    hidden3 = tf.layers.dense(hidden2_stop, n_hidden3, activation=tf.nn.relu,
                              name="hidden3") # reused, not frozen
    hidden4 = tf.layers.dense(hidden3, n_hidden4, activation=tf.nn.relu,
                              name="hidden4") # new!
    logits = tf.layers.dense(hidden4, n_outputs, name="outputs") # new!

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
    loss = tf.reduce_mean(xentropy, name="loss")

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")

# 一つ前の手法と違って更新対象のパラメータを指定していない
with tf.name_scope("train"):
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    training_op = optimizer.minimize(loss)

# 再利用するための事前定義
reuse_vars = tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES,
                               scope="hidden[123]") # regular expression
reuse_vars_dict = dict([(var.op.name, var) for var in reuse_vars])
restore_saver = tf.train.Saver(reuse_vars_dict) # to restore layers 1-3

init = tf.global_variables_initializer()
saver = tf.train.Saver()

with tf.Session() as sess:
    init.run()
    restore_saver.restore(sess, "./my_model_final.ckpt")

    for epoch in range(n_epochs):
        for iteration in range(mnist.train.num_examples // batch_size):
            X_batch, y_batch = mnist.train.next_batch(batch_size)
            sess.run(training_op, feed_dict={X: X_batch, y: y_batch})
        accuracy_val = accuracy.eval(feed_dict={X: mnist.test.images,
                                                y: mnist.test.labels})
        print(epoch, "Test accuracy:", accuracy_val)

    save_path = saver.save(sess, "./my_new_model_final.ckpt")
```

</div></details>


## Caching the Frozen Layers

* Frozen Layers(固定層)のパラメータが変わらない
  * => 訓練データに対する一番上の Frozen Layer の出力も変わらない
* つまり出力結果をキャッシュとして保持しておけば、epoch の度にトレーニングデータの入力からせずに済む
  * (そこは TensorFlow で自動でやってくれない)
* 訓練データが大きかったり、epoch 数が多い場合に有効
* 一番上の Frozen Layer の出力をトレーニングデータとして予め変換して、その後 Frozen Layer ではない層を学習する感じ？

まずはモデルと再利用するための変数の事前定義を行います。
これは上記の `tf.stop_gradient()` を用いたネットワークと全く同じです。

隠れ層2までがパラメータ固定であることに注意してください。

<details><summary>サンプルコード(ネットワークと再利用するための変数定義)</summary><div>

```Python
reset_graph()

n_inputs = 28 * 28  # MNIST
n_hidden1 = 300 # reused
n_hidden2 = 50  # reused
n_hidden3 = 50  # reused
n_hidden4 = 20  # new!
n_outputs = 10  # new!

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu,
                              name="hidden1") # reused frozen
    hidden2 = tf.layers.dense(hidden1, n_hidden2, activation=tf.nn.relu,
                              name="hidden2") # reused frozen & cached
    hidden2_stop = tf.stop_gradient(hidden2)
    hidden3 = tf.layers.dense(hidden2_stop, n_hidden3, activation=tf.nn.relu,
                              name="hidden3") # reused, not frozen
    hidden4 = tf.layers.dense(hidden3, n_hidden4, activation=tf.nn.relu,
                              name="hidden4") # new!
    logits = tf.layers.dense(hidden4, n_outputs, name="outputs") # new!

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
    loss = tf.reduce_mean(xentropy, name="loss")

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")

with tf.name_scope("train"):
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    training_op = optimizer.minimize(loss)

# 再利用するための変数定義
reuse_vars = tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES,
                               scope="hidden[123]") # regular expression
reuse_vars_dict = dict([(var.op.name, var) for var in reuse_vars])
restore_saver = tf.train.Saver(reuse_vars_dict) # to restore layers 1-3

init = tf.global_variables_initializer()
saver = tf.train.Saver()
```

</div></details>
<br>

ここからがキャッシュを行う部分です。
ポイントは以下の通りです。

* 事前(epoch 回す前)に `h2_cache` と `h2_cache_test` を計算する
  * サンプルコードではデータ(`mnist.train.images`、`mnist.test.images`)を一度に全て入力していますが、メモリが足りない場合は小分けに求める必要があります
* epoch 内では `X`, `y` の代わりに `h2_cache` と `hs_cache_test` を使う


<details><summary>サンプルコード(cache を利用した学習)</summary><div>

```Python
import numpy as np

n_batches = mnist.train.num_examples // batch_size

with tf.Session() as sess:
    init.run()
    restore_saver.restore(sess, "./my_model_final.ckpt")

    h2_cache = sess.run(hidden2, feed_dict={X: mnist.train.images})
    h2_cache_test = sess.run(hidden2, feed_dict={X: mnist.test.images}) # not shown in the book

    for epoch in range(n_epochs):
        # 0 から mnsits.train.num_examples - 1 までの数をランダムに並べ替えたもの
        shuffled_idx = np.random.permutation(mnist.train.num_examples)
        # ランダムに並べ替えて、バッチサイズで分割
        hidden2_batches = np.array_split(h2_cache[shuffled_idx], n_batches)
        y_batches = np.array_split(mnist.train.labels[shuffled_idx], n_batches)
        for hidden2_batch, y_batch in zip(hidden2_batches, y_batches):
            sess.run(training_op, feed_dict={hidden2:hidden2_batch, y:y_batch})

        accuracy_val = accuracy.eval(feed_dict={hidden2: h2_cache_test, # not shown
                                                y: mnist.test.labels})  # not shown
        print(epoch, "Test accuracy:", accuracy_val)                    # not shown

    save_path = saver.save(sess, "./my_new_model_final.ckpt")
```

</div></details>
<br>

## Twaeking, Dropping, or Replacing the Upper Layers


## Model Zoos


## Unsupervised Pretraining

# Faster Optimization

* [Optimizer : 深層学習における勾配法について - Qiita](https://qiita.com/tokkuman/items/1944c00415d129ca0ee9)
* [勾配降下法の最適化アルゴリズムを概観する | POSTD](https://postd.cc/optimizing-gradient-descent/)
* 各オプティマイザ概要は上記の素晴らしい記事にまとめられているので、省略します。

TensorFlow でのコードは以下の通りです。

<details><summary>サンプルコード(cache を利用した学習)</summary><div>

```Python
# Momentum
optimizer = tf.train.MomentumOptimizer(learning_rate=learning_rate,
                                       momentum=0.9)
# Nesterov Accelerated Gradient
optimizer = tf.train.MomentumOptimizer(learning_rate=learning_rate,
                                       momentum=0.9, use_nesterov=True)
# AdaGrad
optimizer = tf.train.AdagradOptimizer(learning_rate=learning_rate)
# RMSProp
optimizer = tf.train.RMSPropOptimizer(learning_rate=learning_rate,
                                      momentum=0.9, decay=0.9, epsilon=1e-10)
# Adam Optimization
optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate)
```

</div></details>
<br>

# Learning Rate Scheduling

学習率は他の機械学習アルゴリズムでも頻出パラメータですので、馴染みのある方が多いと思います。
ここでは `tf.exponential_decay()` を用いた学習率の調整方法を紹介します。
`tf.exponential_decay()` では以下のようにして学習率を更新していきます。


```math
decayed_learning_rate = learning_rate * decay_rate ^ {\frac{global_step}/{decay_steps}}
```
またコードについては、学習率調整箇所以外は上記の手法と変わりません。


<details><summary>サンプルコード(モデル定義)</summary><div>

```Python
reset_graph()

n_inputs = 28 * 28  # MNIST
n_hidden1 = 300
n_hidden2 = 50
n_outputs = 10

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu, name="hidden1")
    hidden2 = tf.layers.dense(hidden1, n_hidden2, activation=tf.nn.relu, name="hidden2")
    logits = tf.layers.dense(hidden2, n_outputs, name="outputs")

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
    loss = tf.reduce_mean(xentropy, name="loss")

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")
```

</div></details>

<details><summary>サンプルコード(学習率調整箇所)</summary><div>

```Python
with tf.name_scope("train"):       # not shown in the book
    initial_learning_rate = 0.1
    decay_steps = 10000
    decay_rate = 1/10
    global_step = tf.Variable(0, trainable=False, name="global_step")
    learning_rate = tf.train.exponential_decay(initial_learning_rate, global_step,
                                               decay_steps, decay_rate)
    optimizer = tf.train.MomentumOptimizer(learning_rate, momentum=0.9)
    training_op = optimizer.minimize(loss, global_step=global_step)
```

</div></details>


<details><summary>サンプルコード(学習と評価)</summary><div>

```Python
init = tf.global_variables_initializer()
saver = tf.train.Saver()

n_epochs = 5
batch_size = 50

with tf.Session() as sess:
    init.run()
    for epoch in range(n_epochs):
        for iteration in range(mnist.train.num_examples // batch_size):
            X_batch, y_batch = mnist.train.next_batch(batch_size)
            sess.run(training_op, feed_dict={X: X_batch, y: y_batch})
        accuracy_val = accuracy.eval(feed_dict={X: mnist.test.images,
                                                y: mnist.test.labels})
        print(epoch, "Test accuracy:", accuracy_val)

    save_path = saver.save(sess, "./my_model_final.ckpt")
```

</div></details>

# Avoiding Overfitting Through Regularization

* ここでは過学習を抑制する方法について紹介します

## $l_1$、$l_2$ 正則化

* いずれも自分で定義するか TensorFlow 付属の関数で呼び出せる
* 損失を定義するところに正則化項を加える



### 自分で目的関数を定義

ここでは簡単のため隠れ層が一つのみの場合を考えます。
ポイントは `reg_losses = tf.reduce_sum(tf.abs(W1)) + tf.reduce_sum(tf.abs(W2))` です。
ここで正則化項を定義して元の損失関数に足しています。

またその際に `scale` を正則化項にかけています。これは正則化項の重みです。

<details><summary>サンプルコード</summary><div>

```Python
reset_graph()

n_inputs = 28 * 28  # MNIST
n_hidden1 = 300
n_outputs = 10

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu, name="hidden1")
    logits = tf.layers.dense(hidden1, n_outputs, name="outputs")

W1 = tf.get_default_graph().get_tensor_by_name("hidden1/kernel:0")
W2 = tf.get_default_graph().get_tensor_by_name("outputs/kernel:0")

scale = 0.001 # l1 regularization hyperparameter

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y,
                                                              logits=logits)
    base_loss = tf.reduce_mean(xentropy, name="avg_xentropy")
    reg_losses = tf.reduce_sum(tf.abs(W1)) + tf.reduce_sum(tf.abs(W2))
    # L2 正則化をしたい場合は下記の式を用いる
    # reg_losses = tf.reduce_sum(tf.squere(W1)) + tf.reduce_sum(tf.squere(W2))
    loss = tf.add(base_loss, scale * reg_losses, name="loss")

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")

learning_rate = 0.01

with tf.name_scope("train"):
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    training_op = optimizer.minimize(loss)

init = tf.global_variables_initializer()
saver = tf.train.Saver()

n_epochs = 20
batch_size = 200

with tf.Session() as sess:
    init.run()
    for epoch in range(n_epochs):
        for iteration in range(mnist.train.num_examples // batch_size):
            X_batch, y_batch = mnist.train.next_batch(batch_size)
            sess.run(training_op, feed_dict={X: X_batch, y: y_batch})
        accuracy_val = accuracy.eval(feed_dict={X: mnist.test.images,
                                                y: mnist.test.labels})
        print(epoch, "Test accuracy:", accuracy_val)

    save_path = saver.save(sess, "./my_model_final.ckpt")
```

</div></details>
<br>

### TensorFlow に用意されているものを使う

* ポイントは `tf.layers.dense()` の 引数 `kernel_regularizer` で正則化方法を指定すること
* また共通した引数を持つので `functools.partial()` で同じ引数を省略してあります

<details><summary>サンプルコード</summary><div>

```Python
from functools import partial
reset_graph()

n_inputs = 28 * 28  # MNIST
n_hidden1 = 300
n_hidden2 = 50
n_outputs = 10

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

scale = 0.001

my_dense_layer = partial(
    tf.layers.dense, activation=tf.nn.relu,
    kernel_regularizer=tf.contrib.layers.l1_regularizer(scale))  # ここで L1 正則化指定

with tf.name_scope("dnn"):
    # partial で同じ引数を省略
    hidden1 = my_dense_layer(X, n_hidden1, name="hidden1")
    hidden2 = my_dense_layer(hidden1, n_hidden2, name="hidden2")
    logits = my_dense_layer(hidden2, n_outputs, activation=None,
                            name="outputs")

with tf.name_scope("loss"):                                     # not shown in the book
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(  # not shown
        labels=y, logits=logits)                                # not shown
    base_loss = tf.reduce_mean(xentropy, name="avg_xentropy")   # not shown
    reg_losses = tf.get_collection(tf.GraphKeys.REGULARIZATION_LOSSES)
    loss = tf.add_n([base_loss] + reg_losses, name="loss")

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32), name="accuracy")

learning_rate = 0.01

with tf.name_scope("train"):
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    training_op = optimizer.minimize(loss)

init = tf.global_variables_initializer()
saver = tf.train.Saver()

n_epochs = 20
batch_size = 200

with tf.Session() as sess:
    init.run()
    for epoch in range(n_epochs):
        for iteration in range(mnist.train.num_examples // batch_size):
            X_batch, y_batch = mnist.train.next_batch(batch_size)
            sess.run(training_op, feed_dict={X: X_batch, y: y_batch})
        accuracy_val = accuracy.eval(feed_dict={X: mnist.test.images,
                                                y: mnist.test.labels})
        print(epoch, "Test accuracy:", accuracy_val)

    save_path = saver.save(sess, "./my_model_final.ckpt")
```

</div></details>
<br>

## DropOut

* 各データの学習時に、ある層と層の間の全てのネットワークを使うのではなく、一部を除いて(Dropout した)学習する。
  * 各データ毎にネットワークが少し変わる
* アンサンブル学習となり、精度が上がるとのことです。
* `tf.layers.dropout()` をドロップさせる箇所に挿入する
  * `dropout_rate` はドロップ率


<details><summary>サンプルコード</summary><div>

```Python
reset_graph()

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

training = tf.placeholder_with_default(False, shape=(), name='training')

dropout_rate = 0.5  # == 1 - keep_prob
X_drop = tf.layers.dropout(X, dropout_rate, training=training)

# Dropout する箇所を指定する
with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X_drop, n_hidden1, activation=tf.nn.relu,
                              name="hidden1")
    hidden1_drop = tf.layers.dropout(hidden1, dropout_rate, training=training)
    hidden2 = tf.layers.dense(hidden1_drop, n_hidden2, activation=tf.nn.relu,
                              name="hidden2")
    hidden2_drop = tf.layers.dropout(hidden2, dropout_rate, training=training)
    logits = tf.layers.dense(hidden2_drop, n_outputs, name="outputs")

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
    loss = tf.reduce_mean(xentropy, name="loss")

with tf.name_scope("train"):
    optimizer = tf.train.MomentumOptimizer(learning_rate, momentum=0.9)
    training_op = optimizer.minimize(loss)

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32))

init = tf.global_variables_initializer()
saver = tf.train.Saver()

n_epochs = 20
batch_size = 50

with tf.Session() as sess:
    init.run()
    for epoch in range(n_epochs):
        for iteration in range(mnist.train.num_examples // batch_size):
            X_batch, y_batch = mnist.train.next_batch(batch_size)
            sess.run(training_op, feed_dict={training: True, X: X_batch, y: y_batch})
        acc_test = accuracy.eval(feed_dict={X: mnist.test.images, y: mnist.test.labels})
        print(epoch, "Test accuracy:", acc_test)

    save_path = saver.save(sess, "./my_model_final.ckpt")
```

</div></details>
<br>

## Max norm


<details><summary>サンプルコード(モデル定義)</summary><div>

```Python
reset_graph()

n_inputs = 28 * 28
n_hidden1 = 300
n_hidden2 = 50
n_outputs = 10

learning_rate = 0.01
momentum = 0.9

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
y = tf.placeholder(tf.int64, shape=(None), name="y")

with tf.name_scope("dnn"):
    hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu, name="hidden1")
    hidden2 = tf.layers.dense(hidden1, n_hidden2, activation=tf.nn.relu, name="hidden2")
    logits = tf.layers.dense(hidden2, n_outputs, name="outputs")

with tf.name_scope("loss"):
    xentropy = tf.nn.sparse_softmax_cross_entropy_with_logits(labels=y, logits=logits)
    loss = tf.reduce_mean(xentropy, name="loss")

with tf.name_scope("train"):
    optimizer = tf.train.MomentumOptimizer(learning_rate, momentum)
    training_op = optimizer.minimize(loss)

with tf.name_scope("eval"):
    correct = tf.nn.in_top_k(logits, y, 1)
    accuracy = tf.reduce_mean(tf.cast(correct, tf.float32))
```

</div></details>
<br>

##

#
