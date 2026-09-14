import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: Cnpj(),
  ));
}

class Cnpj extends StatefulWidget {
  const Cnpj({super.key});

  @override
  State<Cnpj> createState() => _CnpjState();
}

class _CnpjState extends State<Cnpj> {
  final cnpj = TextEditingController();

  String empresa = '';

  consultar() async {
    final url = Uri.parse(
      'https://api.opencnpj.org/${cnpj.text}',
    );

    final resposta = await http.get(url);

    final dados = jsonDecode(resposta.body);

    setState(() {
      empresa =
          'Razão Social: ${dados['razao_social']}\n'
          'Nome Fantasia: ${dados['nome_fantasia']}\n'
          'CNPJ: ${dados['cnpj']}\n'
          'Situação: ${dados['situacao_cadastral']}\n'
          'Endereço: ${dados['logradouro']}, ${dados['numero']}\n'
          '${dados['bairro']} - ${dados['municipio']}/${dados['uf']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CNPJ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.business,
              size: 100,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: cnpj,
              decoration: const InputDecoration(
                labelText: 'CNPJ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: consultar,
              child: const Text('Consultar'),
            ),

            const SizedBox(height: 30),

            Text(
              empresa,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}