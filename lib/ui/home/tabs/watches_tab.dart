import 'dart:ui';

import 'package:cobble/domain/connection/connection_state_provider.dart';
import 'package:cobble/domain/entities/pebble_device.dart';
import 'package:cobble/infrastructure/datasources/paired_storage.dart';
import 'package:cobble/ui/common/icons/fonts/rebble_icons_stroke.dart';
import 'package:cobble/ui/common/icons/watch_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cobble/infrastructure/pigeons/pigeons.dart';
import 'package:cobble/domain/entities/pebble_scan_device.dart';
import 'package:cobble/ui/common/icons/fonts/rebble_icons_stroke.dart';
import 'package:cobble/ui/common/icons/watch_icon.dart';
import 'package:cobble/ui/router/cobble_navigator.dart';
import 'package:cobble/ui/router/cobble_scaffold.dart';
import 'package:cobble/ui/setup/pair_page.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/pebble_device.dart';
import '../../../domain/entities/pebble_device.dart';
import '../../common/icons/fonts/rebble_icons_stroke.dart';

class MyWatchesTab extends HookWidget {
  final Color _disconnectedColor = Color.fromRGBO(255, 255, 255, 0.5);
  final Color _connectedColor = Color.fromARGB(255, 0, 255, 170);
  final Color _connectedBrColor = Color.fromARGB(255, 0, 169, 130);

  void getCurrentWatchStatus() {}
  final ConnectionControl connectionControl = ConnectionControl();

  @override
  Widget build(BuildContext context) {
    final connectionState = useProvider(connectionStateProvider.state);
    final defaultWatch = useProvider(defaultWatchProvider);
    final pairedStorage = useProvider(pairedStorageProvider);
    final allWatches = useProvider(pairedStorageProvider.state);

    List<PebbleDevice> allWatchesList =
        allWatches.map((e) => e.device).toList();
    if (defaultWatch != null && connectionState.isConnected == true) {
      //Hide the default watch if we're connected to it. We don't need to see it twice!
      allWatchesList.remove(defaultWatch);
    }

    List<PebbleDevice> defaultWatchList;
    if (defaultWatch != null) {
      defaultWatchList = [defaultWatch];
    } else {
      defaultWatchList = [];
    }

    String statusText;
    bool isConnected;
    if (connectionState.isConnecting == true) {
      statusText = "Connecting...";
      isConnected = false;
    } else if (connectionState.isConnected == true) {
      statusText = "Connected!";
      isConnected = true;
    } else {
      statusText = "Disconnected";
      isConnected = false;
    }

    Color _getBrStatusColor(PebbleDevice device) {
      if (connectionState.currentWatchAddress == device.address)
        return _connectedBrColor;
      else
        return _disconnectedColor;
    }

    Color _getStatusColor(PebbleDevice device) {
      if (connectionState.currentWatchAddress == device.address)
        return _connectedColor;
      else
        return _disconnectedColor;
    }

    void _onDisconnectPressed(bool inSettings) {
      connectionControl.disconnect();
      if (inSettings) Navigator.pop(context);
    }

    void _onConnectPressed(PebbleDevice device, inSettings) {
      NumberWrapper addressWrapper = NumberWrapper();
      addressWrapper.value = device.address;
      connectionControl.connectToWatch(addressWrapper);
      if (inSettings) Navigator.pop(context);
    }

    void _onForgetPressed(PebbleDevice device) {
      pairedStorage.unregister(device.address);
      Navigator.pop(context);
    }

    void _onUpdatePressed(PebbleDevice device) {
      Navigator.pop(context);
      //TODO
    }

    void _onSettingsPressed(PebbleDevice device, bool isConnected) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          builder: (context) {
            return FractionallySizedBox(
              heightFactor: 0.4,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(children: <Widget>[
                      Container(
                        child: Center(
                            child: PebbleWatchIcon(
                                PebbleWatchModel.values[device.color])),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: _getBrStatusColor(device),
                            shape: BoxShape.circle),
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: <Widget>[
                          Text(device.name, style: TextStyle(fontSize: 16)),
                          SizedBox(height: 4),
                          Text(device.address.toString() + " - " + statusText,
                              style: TextStyle(color: _getStatusColor(device))),
                          Wrap(
                            spacing: 4,
                            children: [],
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      Expanded(child: Container(width: 0.0, height: 0.0)),
                    ]),
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 20,
                    thickness: 2,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Offstage(
                    offstage: isConnected,
                    child: ListTile(
                      leading: Icon(RebbleIconsStroke.devices),
                      title: Text('Connect to watch'),
                      onTap: () => _onConnectPressed(device, true),
                    ),
                  ),
                  Offstage(
                    offstage: !isConnected,
                    child: ListTile(
                      leading: Icon(RebbleIconsStroke.devices),
                      title: Text('Disconnect from watch'),
                      onTap: () => _onDisconnectPressed(true),
                    ),
                  ),
                  ListTile(
                    leading: Icon(RebbleIconsStroke.search),
                    title: Text('Check for updates'),
                    onTap: () => _onUpdatePressed(device),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 20,
                    thickness: 2,
                    indent: 15,
                    endIndent: 15,
                  ),
                  ListTile(
                    leading: Icon(RebbleIconsStroke.x_close, color: Colors.red),
                    title: Text('Forget watch',
                        style: TextStyle(color: Colors.red)),
                    onTap: () => _onForgetPressed(device),
                  ),
                ],
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Watches"),
        leading: BackButton(),
      ),
      body: ListView(children: <Widget>[
        Offstage(
            offstage: isConnected,
            child: Column(children: <Widget>[
              Container(
                  child: Row(children: <Widget>[
                    Container(
                      child: Center(child: Icon(Icons.autorenew)),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: _disconnectedColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 16),
                    Column(
                      children: <Widget>[
                        Text("Nothing connected",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Background service stopped"),
                        Wrap(
                          spacing: 4,
                          children: [],
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    Expanded(child: Container(width: 0.0, height: 0.0)),
                  ]),
                  margin: EdgeInsets.all(16)),
            ])),
        Offstage(
          offstage: !isConnected,
          child: Column(
              children: defaultWatchList
                  .map((e) => InkWell(
                        child: Container(
                            child: Row(children: <Widget>[
                              Container(
                                child: Center(
                                    child: PebbleWatchIcon(
                                        PebbleWatchModel.values[e.color])),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                    color: _connectedBrColor,
                                    shape: BoxShape.circle),
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: <Widget>[
                                  Text(e.name, style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text(statusText,
                                      style: TextStyle(color: _connectedColor)),
                                  Wrap(
                                    spacing: 4,
                                    children: [],
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                              Expanded(
                                  child: Container(width: 0.0, height: 0.0)),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: IconButton(
                                  icon: Icon(RebbleIconsStroke.devices,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  onPressed: () => _onDisconnectPressed(false),
                                ),
                              ),
                              IconButton(
                                  icon: Icon(RebbleIconsStroke.menu_vertical,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  onPressed: () => _onSettingsPressed(e, true)),
                            ]),
                            margin: EdgeInsets.all(16)),
                        onTap: () {},
                      ))
                  .toList()),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(15, 25, 15, 5),
            child: Text('All watches', style: TextStyle(fontSize: 18))),
        const Divider(
          color: Colors.white24,
          height: 20,
          thickness: 2,
          indent: 15,
          endIndent: 15,
        ),
        Column(
            children: allWatchesList
                .map((e) => InkWell(
                      child: Container(
                        child: Row(children: <Widget>[
                          Container(
                            child: Center(
                                child: PebbleWatchIcon(
                                    PebbleWatchModel.values[e.color])),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                                color: _disconnectedColor,
                                shape: BoxShape.circle),
                          ),
                          SizedBox(width: 16),
                          Column(
                            children: <Widget>[
                              Text(e.name, style: TextStyle(fontSize: 16)),
                              SizedBox(height: 4),
                              Text(statusText),
                              Wrap(
                                spacing: 4,
                                children: [],
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          Expanded(child: Container(width: 0.0, height: 0.0)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            child: IconButton(
                              icon: Icon(RebbleIconsStroke.devices,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              onPressed: () => _onConnectPressed(e, false),
                            ),
                          ),
                          IconButton(
                              icon: Icon(RebbleIconsStroke.menu_vertical,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              onPressed: () => _onSettingsPressed(e, false)),
                        ]),
                        margin: EdgeInsets.fromLTRB(16, 10, 16, 16),
                      ),
                      onTap: () {},
                    ))
                .toList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/pair'),
        label: Text('PAIR A WATCH'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
