import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Project_Prism/global.dart' as global;

Map data = {};
void promptProfileInfo(Map userData) {
  data = userData;
  global.switchToSecondaryUi(profileInfo());
}

class profileInfo extends StatefulWidget {
  @override
  State<profileInfo> createState() => _profileInfoState();
}

class _profileInfoState extends State<profileInfo>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                global.switchToPrimaryUi();
              },
              icon: Icon(
                Icons.arrow_back,
                color:
                    Theme.of(context).textSelectionTheme.selectionHandleColor,
              ),
            ),
            pinned: true,
            snap: false,
            floating: false,
            backgroundColor: Theme.of(context).focusColor,
            expandedHeight: 300.0,
            elevation: 10,
            centerTitle: true,
            title: global.textWidget(data["firstName"]),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipOval(
                child: data["avatar"] != null
                    ? FadeInImage.assetNetwork(
                        placeholder: "asset/images/loading.gif",
                        image: data["avatar"])
                    : Icon(Icons.person,
                        color: Theme.of(context)
                            .textSelectionTheme
                            .selectionColor!),
              ),
            ),
            bottom: TabBar(
              controller: controller,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.cloud_outlined,
                    color: Theme.of(context).textSelectionTheme.selectionColor,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.beach_access_sharp,
                    color: Theme.of(context).textSelectionTheme.selectionColor,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.brightness_5_sharp,
                      color:
                          Theme.of(context).textSelectionTheme.selectionColor),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 1000,
              child: TabBarView(
                controller: controller,
                children: <Widget>[
                  global.textWidget("Tab 1"),
                  global.textWidget("Tab 2"),
                  global.textWidget("Tab 3"),
                ],
              ),
            ),
          ),
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (BuildContext context, int index) {
          //       return Container(
          //         height: 1000.0,
          //         child: Center(
          //           child: global.textWidget("Implementing process on-going"),
          //         ),
          //       );
          //     },
          //     childCount: 1,
          //   ),
          // ),
        ]));
  }
}
