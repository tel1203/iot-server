# -*- coding: utf-8 -*-

require 'mongo'

#データベースと接続
connection = Mongo::Connection.new
#connection = Mongo::Connection.new('localhost');
#connection = Mongo::Connection.new('localhost'27017);

puts 'データベース一覧'
puts connection.database_names

puts ''
puts 'データベースinfo [名前,byte数]'
connection.database_info.each{ |info| puts info.inspect }

#データベース選択(存在しなければ作成)
db = connection.db('ruby_sample')

#コレクション選択
coll = db.collection('test_coll')

#インサートするドキュメントを作成
doc = {'name' => 'MongoDB', 'type' => 'database', 'count' => 1, 'info' => {'x' => 203, 'y' => '102'}}

#コレクションにドキュメントをインサート
#(データベースが存在しない場合はここで初めて作成される)
id = coll.insert(doc)

#大量のドキュメントをインサート
10.times { |i| coll.insert('i' => i) }

#MongoDBは同じコレクション(テーブル)に異なる形状のドキュメントをインサートすることができます。
#MySQLなどのRDBに比べて非常に柔軟です。

puts ''
puts 'コレクション一覧'
puts db.collection_names

puts ''
puts 'コレクションからドキュメントの最初の一つを取得'
puts coll.find_one

puts ''
puts 'コレクションから全てのドキュメントを取得'
coll.find.each { |row| puts row.inspect }

puts ''
puts 'id指定でドキュメントを取得(id=' + id.to_s + ')'
coll.find('_id' => id).each{ |row| puts row.inspect }

puts ''
puts '\'i\'Fieldが7のものを取得'
coll.find('i' => 7).each{ |row| puts row.inspect }


puts ''
puts 'findで取得したドキュメントはsortで並び替え可能'
puts '並び替えに使用するkeyに\'i\'を指定'
coll.find.sort(:i).each{ |row| puts row.inspect }

puts ''
puts '並び替えに使用するkeyに\'i\'を指定し、方向を降順に指定'
coll.find.sort([:i,:desc]).each{ |row| puts row.inspect }

puts ''
puts '<,>,<=等でドキュメントを取得'
puts '>  : $gt  : greater than'
puts '<  : $lt  : less than'
puts '>= : $gte : greater than equal'
puts '<= : $gte : less than equal'
puts 'i > 5の条件でドキュメントを取得'
coll.find('i' => {'$gt' => 5}).each{ |row| puts row.inspect }

puts '2 < i <= 5の条件でドキュメントを取得'
coll.find('i' => {'$gt' => 2, '$lte' => 5}).each{ |row| puts row.inspect }

puts ''
puts '取得するFieldを指定する.'
puts 'name,typeフィールドを取得(_idは常に返される)'
#チュートリアルのコードが間違っている.
#puts coll.find("_id" => id, :fields => ["name", "type"]).to_a
#上記構文だと_idの部分と:fieldsの部分がAND検索となってしまう.
#https://groups.google.com/d/topic/mongodb-jp/VQUsoNjUnmw/discussion
#希望する動作をさせるには以下のように書く
coll.find({'_id' => id},{:fields => ['name', 'type']}).each{ |row| puts row.inspect }

puts ''
puts '正規表現で絞込み(nameがMから始まるもの)'
coll.find({'name' => /^M/}).each{ |row| puts row.inspect }

puts ''
puts '動的に正規表現を構築'
params = {'search' => 'DB'}
search_string = params['search']

puts 'コンストラクタを使用'
coll.find({'name' => Regexp.new(search_string)}).each{ |row| puts row.inspect }

puts 'リテラルを使用'
coll.find({'name' => /#{search_string}/}).each{ |row| puts row.inspect }

puts ''
puts 'ドキュメントの更新'
puts '更新前'
coll.find({'_id' => id}).each{ |row| puts row.inspect }

#ドキュメントの変更
doc['name'] = 'MongoDB Ruby'
#更新の適用
coll.update({'_id' => id}, doc)
#更新の確認
puts '更新後'
coll.find({'_id' => id}).each{ |row| puts row.inspect }

#単一の値を指定する方法での更新
#$setを指定しないと、{'name':'MongoDB Ruby'}のみのドキュメントになってしまう。
coll.update({'_id' => id}, {'$set' => {'name' => 'MongoDB Ruby'}})


puts ''
puts 'ドキュメントの削除'
puts '削除前のcount'
puts  coll.count
#削除
coll.remove('i' => 7)
puts '削除後のcount'
puts  coll.count

#参照できない
coll.find('i' => 7).each{ |row| puts row.inspect }

puts ''
puts '引数なしのremoveは全てのドキュメントを削除する'
puts '削除前のcount'
puts  coll.count
coll.remove
puts '削除後のcount'
puts  coll.count


puts ''
puts 'コレクションの削除'
puts '削除前'
puts db.collection_names
#削除
coll.drop
puts '削除後'
puts db.collection_names

puts ''
puts 'データベースの削除'
puts '削除前'
puts connection.database_names
#削除
connection.drop_database('ruby_sample')
puts '削除後'
puts connection.database_names
