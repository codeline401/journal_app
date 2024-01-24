import 'dart:async';

mixin Validators {

  //define the validate email
  final validateEmail = 
  StreamTransformer<String, String>.fromHandlers(handleData: (email, sink){
    if (email.contains('@') && email.contains(".")){
      sink.add(email);
    }
    else {
      sink.addError('Entrez une adresse mail valide');
    }
  });

  //define the validate password
  final validatePassword =
  StreamTransformer<String, String>.fromHandlers(handleData: (password, sink){
    if(password.length >= 6){
      sink.add(password);
    }
    else {
      sink.addError('Passowrd needs to be at least 6 characters');
    }
  });
}