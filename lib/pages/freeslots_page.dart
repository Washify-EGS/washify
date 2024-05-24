import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:washify/components/components.dart';
import 'package:washify/pages/washtype_page.dart';

class FreeSlotsPage extends StatelessWidget {
  final List<DateTime> freeSlots;
  final DateTime selectedDate;

  final String userId;

  const FreeSlotsPage({
    super.key,
    required this.freeSlots,
    required this.selectedDate, required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final DateFormat dateFormatter = DateFormat('yMMMMd');

    void _showConfirmationDialog(DateTime slot) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.withOpacity(0.9),
            title: Text(
              "Book Washify for ${timeFormatter.format(slot)} hours of ${dateFormatter.format(selectedDate)}?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.2,
                shadows: [
                  BoxShadow(
                    color: Color.fromARGB(30, 0, 0, 0),
                    blurRadius: 1,
                    offset: Offset(-2, 2),
                  ),
                ],
              ),
            ),
            actions: [
              OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                overflowAlignment: OverflowBarAlignment.center,
                children: [
                  CustomButton(
                    buttonText: 'Go Back',
                    icon2: Icons.arrow_back,
                    width: 130,
                    height: 60,
                    fontSize: 15,
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  CustomButton(
                    buttonText: 'Continue',
                    icon: Icons.arrow_forward,
                    width: 130,
                    height: 60,
                    fontSize: 15,
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WashTypeSelectionPage(
                            selectedSlot: slot,
                            selectedDate: selectedDate,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Washify',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              BoxShadow(
                color: Color.fromARGB(30, 0, 0, 0),
                blurRadius: 1,
                offset: Offset(-2, 2),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Showing free slots on ${dateFormatter.format(selectedDate)}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 40,
                    letterSpacing: 1.2,
                    shadows: [
                      BoxShadow(
                        color: Color.fromARGB(30, 0, 0, 0),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image(
                      image: AssetImage('assets/images/washify_logo.jpeg'),
                      height: 300,
                      width: 600,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please pick one of the following slots to book your car wash:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    letterSpacing: 1.2,
                    shadows: [
                      BoxShadow(
                        color: Color.fromARGB(30, 0, 0, 0),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 650),
                    child: Card(
                      child: Container(
                        height: 400,
                        child: SizedBox(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: freeSlots.length,
                            itemBuilder: (context, index) {
                              final slot = freeSlots[index];
                              final slotTime = timeFormatter.format(slot);
                      
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _showConfirmationDialog(slot);
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      textColor: Colors.white,
                                      leading: const Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        'Free Slot ${index + 1} 🚗',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          letterSpacing: 1.2,
                                          shadows: [
                                            BoxShadow(
                                              color: Color.fromARGB(30, 0, 0, 0),
                                              blurRadius: 1,
                                              offset: Offset(-2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Washify at $slotTime 🕓',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          letterSpacing: 1.2,
                                          shadows: [
                                            BoxShadow(
                                              color: Color.fromARGB(30, 0, 0, 0),
                                              blurRadius: 1,
                                              offset: Offset(-2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  splashColor: Colors.black.withAlpha(30),
                                  highlightColor: Colors.black.withAlpha(50),
                                  hoverColor: Colors.black.withAlpha(50),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
