import 'package:ejemplo_1/services/profile.service.dart';
import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/moneda.dart';
import '../models/profile.model.dart';

class ProfileViewModel extends ChangeNotifier {
  Profile _profile = Profile(
    name: 'Aburik',
    email: 'babarca@utem.cl',
    imageUrl:
        'https://pbs.twimg.com/media/GKQGCy7W8AAzYXT?format=png&name=small',
    discordLink: 'https://discord.com/usuario',
    githubLink: 'https://github.com/TSSW2024',
    facebookLink: 'https://facebook.com/usuario',
    saldototal: 1000.0,
    monedas: [
      Moneda(
        symbol: 'BTCUSDT',
        icon: 'assets/images/bitcoin.png',
        value: 55,
      ),
      Moneda(
        symbol: 'ETHUSDT',
        icon: 'assets/images/ethereum.png',
        value: 15,
      ),
      Moneda(
        symbol: 'LTCUSDT',
        icon: 'assets/images/litecoin.png',
        value: 20,
      ),

      // {'value': 55, 'symbol': 'BTCUSDT', 'icon': 'assets/images/bitcoin.png'},
      // {'value': 15, 'symbol': 'ETHUSDT', 'icon': 'assets/images/ethereum.png'},
      // {'value': 20, 'symbol': 'LTCUSDT', 'icon': 'assets/images/litecoin.png'},
    ],
  );

  ProfileViewModel(ProfileService profileService);

  Profile get profile => _profile;

  get errorMessage => null;

  bool? get isLoading => null;

  void updateProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }
}
