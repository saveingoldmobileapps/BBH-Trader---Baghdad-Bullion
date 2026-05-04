import 'package:flutter/material.dart';

/// ================= ENUM =================
enum PageType { content, form }

/// ================= MODELS =================
class BBHPageData {
  final PageType type;
  final String section;
  final String title;
  final String description;

  final List<String>? items;
  final List<FormFieldData>? fields;

  BBHPageData({
    required this.type,
    required this.section,
    required this.title,
    required this.description,
    this.items,
    this.fields,
  });
}

class FormFieldData {
  final String label;
  final TextEditingController controller;
  final bool isCheckbox;
  bool checkboxValue;

  FormFieldData({
    required this.label,
    TextEditingController? controller,
    this.isCheckbox = false,
    this.checkboxValue = false,
  }) : controller = controller ?? TextEditingController();
}

/// ================= SCREEN =================
class BBHOnboardingScreen extends StatefulWidget {
  const BBHOnboardingScreen({super.key});

  @override
  State<BBHOnboardingScreen> createState() => _BBHOnboardingScreenState();
}

class _BBHOnboardingScreenState extends State<BBHOnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  late final List<BBHPageData> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      /// ✅ PAGE 1 (CONTENT)
      BBHPageData(
        type: PageType.content,
        section: "SECTION 1 · PURPOSE & SCOPE",
        title: "Before we begin",
        description:
            "Please read the following with the Client. The agent shall confirm understanding before proceeding.",
        items: [
          "1.1 What this pack is for. The Bank account opened under this pack is used only to settle the Client’s gold transactions with BBH — paying BBH for purchases and receiving funds for sales.",
          "1.2 BBH’s role. BBH collects this information on behalf of the Bank. The Bank holds the account; BBH handles the gold leg of every transaction.",
          "1.3 Paper and digital records. Two items are required for compliance and record keeping.",
        ],
      ),

      /// ✅ PAGE 2 (FORM)
      BBHPageData(
        type: PageType.form,
        section: "SECTION 2 · CLIENT DETAILS",
        title: "Client Information",
        description: "Enter client details.",
        fields: [
          FormFieldData(label: "Full Name"),
          FormFieldData(label: "Email"),
          FormFieldData(
            label: "I confirm the information is correct",
            isCheckbox: true,
          ),
        ],
      ),

      /// ✅ PAGE 3 (FORM)
      BBHPageData(
        type: PageType.form,
        section: "SECTION 3 · DECLARATION",
        title: "Declaration",
        description: "Please confirm.",
        fields: [
          FormFieldData(
            label: "I agree to terms and conditions",
            isCheckbox: true,
          ),
        ],
      ),
    ];
  }

  void nextPage() {
    final page = pages[currentPage];

    /// ✅ VALIDATION
    if (page.type == PageType.form) {
      bool isValid = true;

      for (var field in page.fields!) {
        if (field.isCheckbox) {
          if (!field.checkboxValue) isValid = false;
        } else {
          if (field.controller.text.trim().isEmpty) isValid = false;
        }
      }

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete required fields")),
        );
        return;
      }
    }

    /// ✅ NEXT
    if (currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      /// FINAL ACTION
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = pages.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage("assets/png/app_ic.png"),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BBH",

                            style: TextStyle(
                              fontFamily: 'DINNextArabic',
                              // fontWeight: FontWeight.w100, // Bold
                              // fontSize: 32,
                              letterSpacing: 1.5,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text("BNK - 001.v1.O"),
                        ],
                      ),
                    ],
                  ),
                  Text("${currentPage + 1} of $totalPages"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// PROGRESS BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double progress = (currentPage + 1) / totalPages;

                  return Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6DED0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFA46F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// PAGES
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(pages[index]);
                },
              ),
            ),

            /// CONTINUE BUTTON
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16243C),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("CONTINUE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= PAGE SWITCH =================
  Widget _buildPage(BBHPageData page) {
    if (page.type == PageType.content) {
      return _buildContentPage(page);
    } else {
      return _buildFormPage(page);
    }
  }

  /// ================= CONTENT PAGE =================
  // Widget _buildContentPage(BBHPageData page) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.symmetric(horizontal: 24),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(page.section,
  //             style: const TextStyle(color: Color(0xFF9A7B3F))),
  //         const SizedBox(height: 12),

  //         Text(page.title,
  //             style:
  //                 const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

  //         const SizedBox(height: 8),

  //         Container(height: 2, width: 40, color: Color(0xFFBFA46F)),

  //         const SizedBox(height: 16),

  //         Text(page.description, style: const TextStyle(color: Colors.grey)),

  //         const SizedBox(height: 20),

  //         ...page.items!.map(
  //           (e) => Padding(
  //             padding: const EdgeInsets.only(bottom: 12),
  //             child: Text(e),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildContentPage(BBHPageData page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            page.section,
            style: const TextStyle(
              color: Color(0xFF9A7B3F),
              letterSpacing: 1.2,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            page.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16243C),
            ),
          ),

          const SizedBox(height: 12),

          /// ✅ CENTERED SHORT DIVIDER (FIXED)
          Center(
            child: Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFBFA46F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            page.description,
            style: const TextStyle(
              color: Color(0xFF6F6F6F),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          /// ✅ Better formatted items (1.1, 1.2)
          ...List.generate(page.items!.length, (index) {
            final item = page.items![index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TEXT
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ),

                /// ✅ DIVIDER (ONLY BETWEEN ITEMS)
                if (index != page.items!.length - 1)
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFFE6DED0),
                    ),
                  ),
              ],
            );
          }),

          // ...page.items!.map(
          //   (e) => Padding(
          //     padding: const EdgeInsets.only(bottom: 16),
          //     child: Text(
          //       e,
          //       style: const TextStyle(
          //         fontSize: 15,
          //         height: 1.6,
          //         color: Color(0xFF2E2E2E),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  /// ================= FORM PAGE =================

  Widget _buildFormPage(BBHPageData page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            page.section,
            style: const TextStyle(
              color: Color(0xFF9A7B3F),
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            page.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16243C),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            page.description,
            style: const TextStyle(color: Color(0xFF6F6F6F)),
          ),

          const SizedBox(height: 24),

          ...page.fields!.map((field) {
            if (field.isCheckbox) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: field.checkboxValue,
                activeColor: const Color(0xFFBFA46F),
                onChanged: (val) {
                  setState(() {
                    field.checkboxValue = val ?? false;
                  });
                },
                title: Text(
                  field.label,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: field.controller,
                  decoration: InputDecoration(
                    labelText: field.label,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
