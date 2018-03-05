# Reusing Models from Other Frameworks

ここでは他のフレームワーク(自作含む)で求めたパラメータで Tensorflow のネットワークを構築する方法を紹介します。
(互換性のあるフレームワークなら用意してある関数使ったほうが良いと思います)

今回は互換性が全くない状態を想定します。
事前に以下のようにして他のフレームワーク等からパラメータを抽出してある状態を想定しています。

```Python
reset_graph()

n_inputs = 2
n_hidden1 = 3

original_w = [[1., 2., 3.], [4., 5., 6.]]  # weight, 他のフレームワークから持ってる
original_b = [7., 8., 9.]                  # bias, 他のフレームワークから持ってる

X = tf.placeholder(tf.float32, shape=(None, n_inputs), name="X")
hidden1 = tf.layers.dense(X, n_hidden1, activation=tf.nn.relu, name="hidden1")
# [...] 以下に自分で組んだ他の層が定義されているとする
```

上記で組んだモデルに対し、隠れ層1のパラメータに `original_w` と `original_b` を適用します。


## (比較的)簡潔な方法

ここでの "kernel" は "weights" のことを指しています。
おおまかな流れは以下の通りです。

* `graph.get_operation_by_name` で該当の層の kernel(weights) や bias の Operation オブジェクトをとってくる
* 各 Operation オブジェクトへの入力の参照？を `init_kernel` と `init_bias` に渡す(参照を渡してる？)
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
