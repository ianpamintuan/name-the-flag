// ActionScript file
import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.events.Event;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;

import mx.collections.ArrayCollection;

[Bindable]
public var conn:SQLConnection = new SQLConnection();

[Bindable]
private var stmt:SQLStatement = new SQLStatement();

[Bindable]
private var highscoreList:ArrayCollection = new ArrayCollection();

private function dbinit(event:Event):void
{
	var dir:File = File.applicationDirectory;
	//
	var db:File = dir.resolvePath("scores.db");
	conn.openAsync(db);
	conn.addEventListener(SQLEvent.OPEN, dbLoaded);
	conn.addEventListener(SQLErrorEvent.ERROR, sqlError);
	conn.addEventListener(SQLEvent.RESULT, sqlResult);
}

public function isDbConnected(conDb:SQLConnection):SQLConnection{
	var dir:File = File.applicationDirectory;
	var db:File = dir.resolvePath("scores.db");
	if(!conDb.connected){
		conDb.open(db);
		conn.addEventListener(SQLEvent.OPEN, dbLoaded);
		conn.addEventListener(SQLErrorEvent.ERROR, sqlError);
		conn.addEventListener(SQLEvent.RESULT, sqlResult);
	}
	return conDb;
}


private function dbLoaded(op:SQLEvent):void{
	
	stmt.sqlConnection = conn;
	
	stmt.text = "CREATE TABLE IF NOT EXISTS highscores ( id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Score INTEGER);";
	
	stmt.execute();
	
}

private function sqlError(err:SQLErrorEvent):void{
	trace(err.error.message);
}
private function sqlResult(res:SQLEvent):void{

			var data:Array = stmt.getResult().data;
			
			for(var d:int=0;d<=data.length-1;d++)
			{
				highscoreList.addItem({Name:data[d].Name,Score:data[d].Score});
			}
				
}

private function insertScore(name:String, score:int):void
{
	stmt.sqlConnection = this.isDbConnected(conn);
	
	stmt.text = "INSERT INTO highscores (Name, Score) VALUES('"+name+"','"+score+"');";
	
	stmt.execute();
	
}

private function selectScores():void
{
	stmt.sqlConnection = this.isDbConnected(conn);
	stmt.text = "SELECT Name,Score FROM highscores ORDER BY Score DESC LIMIT 10";	
	stmt.addEventListener(SQLErrorEvent.ERROR, sqlError);	
	stmt.addEventListener(SQLEvent.RESULT, sqlResult);
	stmt.execute();
	
}

private function displayFunc(item:Object):String {
		
		return item.Name + "\t\t\t" + item.Score;

}

private function resetScores():void{

	stmt.sqlConnection = this.isDbConnected(conn);
	
	stmt.text = "DELETE FROM highscores";
	stmt.execute();
	
}