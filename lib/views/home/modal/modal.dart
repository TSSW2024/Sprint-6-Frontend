import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DescubrirModal extends StatefulWidget {
  @override
  State<DescubrirModal> createState() => _DescubrirModalState();
}

class _DescubrirModalState extends State<DescubrirModal> {
void handleLootSelection(String tipoCaja) {
  String endpoint;
  if (tipoCaja == 'normal') {
    endpoint = 'https://api-loot.tssw.cl/caja1';
  } else if (tipoCaja == 'premium') {
    endpoint = 'https://api-loot.tssw.cl/caja2';
  } else {
    return; // Si el tipo de caja no es válido, no hacer nada
  }

  Navigator.pushNamed(
    context,
    '/Loot',
    arguments: endpoint,
  );
}


  @override
  Widget build(BuildContext context) {
    double buttomNavBarWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      minChildSize: 0.32,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          width: buttomNavBarWidth,
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 10,
                child: Container(
                  width: 60,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 164, 164, 164),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/images/box.svg',
                            height: 22,
                            width: 23,
                          ),
                          title: const Text('Caja Normal'),
                          trailing: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              '55.000 CLP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          onTap: () {
                            handleLootSelection('normal');
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/images/gift_box.svg',
                              height: 22,
                              width: 23,
                            ),
                            title: const Text('Caja Premium'),
                            trailing: const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                '100.000 CLP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onTap: () {
                              handleLootSelection('premium');
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
