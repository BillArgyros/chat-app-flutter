//this method is responsible for clearing any with space before and after the beginning of the message
String clearChatTextWhiteSpace(text) {
  text = text.trimLeft();
  text = text.trimRight();
  return text;
}