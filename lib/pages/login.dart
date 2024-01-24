import 'package:flutter/material.dart';
import 'package:journal/blocs/login_bloc.dart';
import 'package:journal/services/authentication.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(AutheticationService());
  }

  @override
  void dispose(){
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40.0), 
          child: Icon(Icons.account_circle, size: 88.0, color: Colors.white,),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder(
                stream: _loginBloc.email, 
                builder: (BuildContext context, AsyncSnapshot snapshot) => TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    icon: const Icon(Icons.mail_outline),
                    errorText: snapshot.error as String?
                  ),
                  onChanged: _loginBloc.emailChanged.add,
                ),
              ),
              StreamBuilder(
                stream: _loginBloc.password, 
                builder: (BuildContext context, AsyncSnapshot snapshot) => TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    icon: const Icon(Icons.security),
                    errorText: snapshot.error as String?,
                  ),
                  onChanged: _loginBloc.passwordChanged.add,
                ),
              ),
              const SizedBox(height: 48.0,),
              _buildLoginAndCreateButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginAndCreateButtons() {
    return StreamBuilder(
      initialData: 'Login',
      stream: _loginBloc.loginOrCreateButton, 
      builder: ((BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.data == 'Login'){
          return _buttonLogin();
        }
        else if (snapshot.data == 'Create Account'){
          return _buttonCreateAccount();
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Column _buttonLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder(
          initialData: false,
          stream: _loginBloc.enableLoginCreateButton, 
          builder: (BuildContext context, AsyncSnapshot snapshot) =>
            ElevatedButton(
              onPressed: snapshot.data ? () => _loginBloc.loginOrCreateChanged.add('Login') : null, 
              child: const Text('Login'),
            ),
        ),
        TextButton(
          onPressed: () {
            _loginBloc.loginOrCreateButtonChanged.add('Create Account');
          }, 
          child: const Text('Create Account'),
        )
      ],
    );
  }

  Column _buttonCreateAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder(
          stream: _loginBloc.enableLoginCreateButton, 
          builder: (BuildContext context, AsyncSnapshot snapshot) =>
            ElevatedButton(
              onPressed: snapshot.data ? () => _loginBloc.loginOrCreateChanged.add('Create Account') : null, 
              child: const Text('Create Account'),
            )
        ),
        TextButton(
          onPressed: () {
            _loginBloc.loginOrCreateButtonChanged.add('Login');
          }, 
          child: const Text('Login'),
        )
      ],
    );
  }
}