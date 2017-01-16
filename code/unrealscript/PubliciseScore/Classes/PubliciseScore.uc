
/* WARNING! This file was auto-generated by jpp.  You probably want to be editing ./PubliciseScore.uc.jpp instead. */

class PubliciseScore extends Mutator config(PubliciseScore);
// TODO: Introduce format %s/%S=score %p=playercount %t/%T=timeleft ...
// Title:
var config bool bShowTeamCounts;
var config bool bShowTeamScore;
var config bool bShowTeamNames;
var config bool bShowTime;
var config int UpdateInterval;
// To Player on entry:
var config bool bInformEnterText;
var config bool bInformSpeed;
// Leave this in.  People may find it useful, and it defaults to off anyway.
var config bool bCycleServerName;
var config bool bOnlyCycleWhenEmpty;
var config String CycledServerName[20];
var int CycleNum;
var bool Initialized;
var string titleDefault;
defaultproperties {
 bShowTeamCounts=False // Only really wanted on XOL well we had the incorrect count in query
 bShowTeamScore=True
 bShowTeamNames=False
 bShowTime=True
 UpdateInterval=16
 bInformEnterText=False
 bInformSpeed=False
 bCycleServerName=False
 bOnlyCycleWhenEmpty=True
 CycledServerName(0)="default"
 // CycledServerName(1)="[running PubliciseScore with bCycleServerName enabled]"
 // CycledServerName(2)="[server admin should edit CycledServerName[0-20] in PubliciseScore.ini]"
 // CycledServerName(0)="default"
 // CycledServerName(1)="No Downloads we miss your grapple!"
 // CTF/DM/MapVote
}
function PostBeginPlay() {
 if (Initialized) {
  Log("PubliciseScore.PostBeginPlay(): Already initialised!");
  return;
 }
 Initialized = True;
 titleDefault = ""; // seems title is not set at this time; so we will load it later
 if ((bShowTeamScore && Level.Game.IsA('TeamGamePlus')) || bShowTime) { // no point running if not needed
  SetTimer(UpdateInterval,True);
 } else {
  SetTitle("");
 }
}
// This is not currently working because ModifyPlayer is only called on mutators :P
function ModifyPlayer(Pawn p) {
 // local String s;
 // local int max;
 if (p.PlayerReplicationInfo.Deaths == 0) {
  if (bInformEnterText && Level.LevelEnterText != "") {
   p.ClientMessage(Level.LevelEnterText);
  }
  if (bInformSpeed && Level.Game.GameSpeed != 1.0) {
   // p.ClientMessage( titleDefault$" at "$Int(Level.Game.GameSpeed*100)$" speed" );
   p.ClientMessage( "Gamespeed is "$Int(Level.Game.GameSpeed*100)$"%");
  }
  // TODO: I am doing this here, so that if the server does fill,
  // it can expand maxplayers by 2 ^^
  // ?? That seems daft :P
  // if (bSetPlayersFromMap) {
  // TODO:
  // Get numbers from the map's idealplayercount
  // If there are two numbers, take the largest
  // Set maxplayers to that value!
  // s = InStrLast(""Level.GameInfo.IdealPlayerCount,
  // }
 }
 Super.ModifyPlayer(p);
}
event Timer() {
 local string text;
 local int redScore, blueScore;
 // local int gameDuration;
 local int timeLeft;
 local PlayerPawn p;
 local int redCount,blueCount;
 text = " ";
 if (Level.Game.IsA('TeamGamePlus')) {
  if (bShowTeamCounts) {
   foreach AllActors(class'PlayerPawn',P) {
    if (P.PlayerReplicationInfo.Team == 0)
     redCount++;
    if (P.PlayerReplicationInfo.Team == 1)
     blueCount++;
   }
   if (redCount + blueCount > 0)
    text = text $ "("$ redCount $"v"$ blueCount $") ";
  }
  if (bShowTeamScore) {
   redScore = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo).Teams[0].Score;
   blueScore = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo).Teams[1].Score;
   if (redScore>0 || blueScore>0) {
    if (bShowTeamNames) {
     text = text $ "[Red:"$redScore$" Blue:"$blueScore$"] ";
    } else {
     text = text $ "["$redScore$"-"$blueScore$"] ";
    }
   }
  }
 }
 if (bShowTime && DeathMatchPlus(Level.Game).TimeLimit>0) {
  // Log("TimeSeconds="$Level.TimeSeconds$" TimeLimit="$DeathMatchPlus(Level.Game).TimeLimit$" StartTime="$Level.Game.StartTime$" CountDown="$DeathMatchPlus(Level.Game).CountDown$" NetWait="$DeathMatchPlus(Level.Game).NetWait$" ElapsedTime="$DeathMatchPlus(Level.Game).ElapsedTime);
  // Log("TimeSeconds="$Level.TimeSeconds$" ElapsedTime="$DeathMatchPlus(Level.Game).ElapsedTime$" GRI.RemainingTime="$Level.Game.GameReplicationInfo.RemainingTime$" GRI.ElapsedTime="$Level.Game.GameReplicationInfo.ElapsedTime$" GRI.RemainingMinute="$Level.Game.GameReplicationInfo.RemainingMinute$" GRI.SecondCount="$Level.Game.GameReplicationInfo.SecondCount);
  // gameDuration = Level.TimeSeconds - Level.Game.StartTime;
  // gameDuration = DeathMatchPlus(Level.Game).ElapsedTime - DeathMatchPlus(Level.Game).CountDown;
  // gameDuration = Level.Game.GameReplicationInfo.ElapsedTime;
  // timeLeft = DeathMatchPlus(Level.Game).TimeLimit*60 - gameDuration;
  // Log("gameDuration="$gameDuration$" timeLeft="$timeLeft);
  if (DeathMatchPlus(Level.Game).ElapsedTime == 0) { // ElapsedTime goes from 0 to 9 during start-game countdown
   // waiting for players
   // text = text $ "Waiting for players...";
   text = ""; // no point showing 0-0 before the game has started!
  } else {
   if (Level.Game.bGameEnded) {
    text = text $ "Game ended";
   } else {
    timeLeft = Level.Game.GameReplicationInfo.RemainingTime;
    if (timeLeft>0) {
     // if (timeLeft>=60) {
     // text = text $ (timeLeft/60) $ "m";
     // }
     //// Since our Timer is called infrequently, we don't show seconds
     // text = text $ (timeLeft%60) $ "s";
     // text = text $ " left";
     if ((timeLeft/60) == 1) {
      text = text $ (timeLeft/60) $ " minute remaining";
     } else {
      text = text $ (timeLeft/60) $ " minutes remaining";
     }
     // text = text $ " ";
    } else {
     text = text $ "Overtime!";
    }
   }
  }
 }
 SetTitle(text);
}
function SetTitle(String newText) {
 local String localTitle;
 // local String serverName;
 // serverName = Level.Game.GameReplicationInfo.ServerName;
 // // serverName = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo).ServerName;
 // Log("PubliciseScore.SetTitle(): current title is \"" $ serverName $ "\".");
 // if (StrEndsWith(serverName,"] ")) {
 // serverName = StrBeforeLast(serverName," [");
 // }
 // if (newText != "") {
 // serverName = serverName $ " [" $ newText $ "] ";
 // }
 // Log("PubliciseScore.SetTitle(): new title is \"" $ serverName $ "\".");
 // Level.Game.GameReplicationInfo.ServerName = serverName;
 if (titleDefault == "") {
  titleDefault = Level.Game.GameReplicationInfo.ServerName;
 }
 // Log("PubliciseScore.SetTitle(): setting server title to \"" $ titleDefault $ newText $ "\".");
 Level.Game.GameReplicationInfo.ServerName = titleDefault $ newText;
 if (bCycleServerName) {
  if (CycleNum>=20 || CycledServerName[CycleNum] == "")
   CycleNum = 0;
  localTitle = CycledServerName[CycleNum];
  if (localTitle == "default" || localTitle == "")
   localTitle = titleDefault;
  Level.Game.GameReplicationInfo.ServerName = localTitle $ newText;
  CycleNum++;
 } else {
  Level.Game.GameReplicationInfo.ServerName = titleDefault $ newText;
 }
 // TODO: If there are any '\'s in the string, they will not make it through the server query response!
 Level.Game.GameReplicationInfo.ServerName = FilterSlashes( Level.Game.GameReplicationInfo.ServerName );
 // Log("Set server title to: "$Level.Game.GameReplicationInfo.ServerName);
}
function String FilterSlashes(String str) {
 return StrReplaceAll(str,"\\","/");
}
//===============//
//               //
//  JLib.uc.jpp  //
//               //
//===============//
function int SplitString(String str, String divider, out String parts[256]) {
 // local String parts[256];
 // local array<String> parts;
 local int i,nextSplit;
 i=0;
 while (true) {
  nextSplit = InStr(str,divider);
  if (nextSplit >= 0) {
   // parts.insert(i,1);
   parts[i] = Left(str,nextSplit);
   str = Mid(str,nextSplit+Len(divider));
   i++;
  } else {
   // parts.insert(i,1);
   parts[i] = str;
   i++;
   break;
  }
 }
 // return parts;
 return i;
}
function string GetDate() {
 local string Date, Time;
 Date = Level.Year$"/"$PrePad(Level.Month,"0",2)$"/"$PrePad(Level.Day,"0",2);
 Time = PrePad(Level.Hour,"0",2)$":"$PrePad(Level.Minute,"0",2)$":"$PrePad(Level.Second,"0",2);
 return Date$"-"$Time;
}
// NOTE: may cause an infinite loop if p=""
function string PrePad(coerce string s, string p, int i) {
 while (Len(s) < i)
  s = p$s;
 return s;
}
function bool StrStartsWith(string s, string x) {
 return (InStr(s,x) == 0);
 // return (Left(s,Len(x)) ~= x);
}
function bool StrEndsWith(string s, string x) {
 return (Right(s,Len(x)) ~= x);
}
function bool StrContains(String s, String x) {
 return (InStr(s,x) > -1);
}
function String StrAfter(String s, String x) {
 return StrAfterFirst(s,x);
}
function String StrAfterFirst(String s, String x) {
 return Mid(s,Instr(s,x)+Len(x));
}
function string StrAfterLast(string s, string x) {
 local int i;
 i = InStr(s,x);
 if (i == -1) {
  return s;
 }
 while (i != -1) {
  s = Mid(s,i+Len(x));
  i = InStr(s,x);
 }
 return s;
}
function string StrBefore(string s, string x) {
 return StrBeforeFirst(s,x);
}
function string StrBeforeFirst(string s, string x) {
 local int i;
 i = InStr(s,x);
 if (i == -1) {
  return s;
 } else {
  return Left(s,i);
 }
}
function string StrBeforeLast(string s, string x) {
 local int i;
 i = InStrLast(s,x);
 if (i == -1) {
  return s;
 } else {
  return Left(s,i);
 }
}
function int InStrOff(string haystack, string needle, int offset) {
 local int instrRest;
 instrRest = InStr(Mid(haystack,offset),needle);
 if (instrRest == -1) {
  return instrRest;
 } else {
  return offset + instrRest;
 }
}
function int InStrLast(string haystack, string needle) {
 local int pos;
 local int posRest;
 pos = InStr(haystack,needle);
 if (pos == -1) {
  return -1;
 } else {
  posRest = InStrLast(Mid(haystack,pos+Len(needle)),needle);
  if (posRest == -1) {
   return pos;
  } else {
   return pos + Len(needle) + posRest;
  }
 }
}
// Converts a string to lower-case.
function String Locs(String in) {
 local String out;
 local int i;
 local int c;
 out = "";
 for (i=0;i<Len(in);i++) {
  c = Asc(Mid(in,i,1));
  if (c>=65 && c<=90) {
   c = c + 32;
  }
  out = out $ Chr(c);
 }
 return out;
}
// Will get all numbers from string.
// If breakAtFirst is set, will get first number, and place the remainder of the string in rest.
// Will accept all '.'s only leading '-'s
function String StrFilterNum(String in, optional bool breakAtFirst, optional out String rest) {
 local String out;
 local int i;
 local int c;
 local bool onNum;
 out = "";
 onNum = false;
 for (i=0;i<Len(in);i++) {
  c = Asc(Mid(in,i,1));
  if ( (c>=Asc("0") && c<=Asc("9")) || c==Asc(".") || (c==Asc("-") && !onNum) ) {
   out = out $ Chr(c);
   onNum = true;
  } else {
   if (onNum && breakAtFirst) {
    // onNum = false;
    // out = out $ " ";
    rest = Mid(in,i);
    return out;
   }
  }
 }
 rest = "";
 return out;
}
// UT2k4 had Repl(in,search,replace).
function String StrReplace(String in, String search, String replace) {
 return StrReplaceAll(in,search,replace);
}
function String StrReplaceAll(String in, String search, String replace) {
 local String out;
 local int i;
 out = "";
 for (i=0;i<Len(in);i++) {
  if (Mid(in,i,Len(search)) == search) {
   out = out $ replace;
   i = i + Len(search) - 1;
  } else {
   out = out $ Mid(in,i,1);
  }
 }
 return out;
}
function String StrPop(out String str, String delimiter) {
 local int i;
 local String result;
 i = InStr(str,delimiter);
 if (i>=0) {
  result = Left(str,i);
  str = Mid(str,i+Len(delimiter));
 } else {
  result = str;
  str = "";
 }
 return result;
}
