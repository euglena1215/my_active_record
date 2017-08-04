# my_active_record
自学用に作った劣化activerecord  
[my_sqlite3_core](https://github.com/euglena1215/my_sqlite3_core) を利用しています。

## 実装したメソッド

* set_database(db_path, type)  
	どの種類(type)のどこに保存されている(db_path)DBを利用するのか設定する。
  
* TableClass.new(attribute)  
	レコードオブジェクトを生成する。
  
* TableClass#{column名}  
	レコードオブジェクトのカラムデータを参照する。
  
* TableClass#{column名}=  
	レコードオブジェクトのカラムデータに書き込む。
  
* TableClass.all  
	Tableのレコードオブジェクトを全件取得する。
  
* TableClass.find(id)  
	同一のidをもつTableのレコードオブジェクトを1件取得する。
  
* TableClass.where(condition)  
	conditionに合致するTableのレコードオブジェクトを全件取得する。
  
* TableClass#save  
	レコードオブジェクトの情報をDBに保存する。
  
* TableClass#update(attribute)  
	レコードオブジェクトの更新をDBに反映させる。
  
* TableClass#destroy  
	レコードオブジェクトをDBから削除する。
  
* TableClass.belongs_to(table)  
	Tableがtableに所属しているリレーションをTableClassに反映させる。
  
* TableClass.has_many(tables)  
	Tableは複数のtableを所持しているリレーションをTableClassに反映させる。
  
