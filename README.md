What is this?
=============

AWSの請求をプロジェクトごとにわける設定を

[Qiita に書いた](http://qiita.com/PharaohKJ/items/96dff3f6c0513f5a100f)

わけだが、結局どのプロジェクトに何パーセント使ってるのかさっと見たかったため作ったもの。

実行すると最後に、totalいくら、どのプロジェクトにいくら(割合)まで表示される。

```
none : 193.34061300000002 (0.9766650484946454)
total : 197.96 (1.0)
alpha : 4.619387 (0.023334951505354615)
```

How to Use
==========

1. 上記 Qiita の私の記事を読んで、S3にプロジェクトごとに出力させる。
2. `cp env.rb.sample env.rb` して中身を自分のAmazonS3にカスタム。
3. `bundle install --standalone`
4. `bundle exec ruby main.rb`

Next Version
============

今のはシンプルにできているけれど、ちょっと MongoDB で遊んでみたいと考えている。
