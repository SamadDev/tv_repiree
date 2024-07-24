import 'package:flutter/material.dart';


class SearchItem extends StatelessWidget {
  final TextEditingController? searchController;
  final String? hint;
  final Function(String?)? onChange;
  final bool autoFocus;
  const SearchItem({Key? key, this.searchController, this.hint, this.onChange, this.autoFocus = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.white,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 14),
                child: TextFormField(
                  autofocus: autoFocus,
                  controller: searchController,
                  onChanged: onChange,
                  decoration: InputDecoration(
                      hintText: "$hint",
                      border: InputBorder.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
