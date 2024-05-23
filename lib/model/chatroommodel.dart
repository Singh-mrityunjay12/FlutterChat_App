// ignore: camel_case_types
class chatroomModel {
  String? chatroomId;

  Map<String, dynamic>?
      participants; //isame jo bhi log conversation karenge usake uid honge

  String?
      lastmessage; //last massage kaya kiya tha usako dikhane ke in home page per
  // DateTime? createdOn;
  chatroomModel({
    this.chatroomId,
    this.participants,
    this.lastmessage,
  });
//we will use when data fetch from firebase to convert into object
  chatroomModel.fromMap(Map<String, dynamic> map) {
    chatroomId = map['chatroomId'];
    participants = map['participants'];
    lastmessage = map['lastmessage'];
    // createdOn = map['createdOn'].toDate();
  }
//we will use when data give from mainualy to store into database(convert object to map)
  Map<String, dynamic> toMap() {
    return {
      'chatroomId': chatroomId,
      'participants': participants,
      'lastmessage': lastmessage,
      // 'createdOn': createdOn,
    };
  }
}
