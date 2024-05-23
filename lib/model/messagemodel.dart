//message model ke through message send karenge chatModel me
class messageModel {
  String? messageId; //kyoki each and every message ki ak unic id hogi
  String? sender; //message bhejane vale honge
  String? text; //kya text bheja sender ne vo hoga
  bool? seen; //message ko seen kiya or nahi true or false ke through
  DateTime? createdOn; //message kab bheja timing

  messageModel(
      {this.messageId, this.sender, this.text, this.seen, this.createdOn});

//firebase or api se data lenge to ham fromMap karenge usase object banayege
  messageModel.fromMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdOn = map['createdOn']
        .toDate(); //yaha toDate( isliye lagaya h ki jab bhi ham firebase me store karate h to vaha as  timestamp store hoata h aur time stamp ko vapas date me convert karane ke liye karate h)
  }
  //toMap ka use karake ham object se map banayege jise firebse database me save karenge
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdOn': createdOn,
    };
  }
}
