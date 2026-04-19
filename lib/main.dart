import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Expense {
  double amount;
  String category;

  Expense(this.amount, this.category);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: ExpensePage(),
    );
  }
}

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  List<Expense> expenses = [];
  String selectedCategory = "Food";

  double total = 0;

  void addExpense() {
    if (amountController.text.isEmpty) return;

    double amount = double.parse(amountController.text);

    setState(() {
      expenses.add(Expense(amount, selectedCategory));
      total += amount;
    });

    checkBudget();
    amountController.clear();
  }

  void deleteExpense(int index) {
    setState(() {
      total -= expenses[index].amount;
      expenses.removeAt(index);
    });
  }

  void resetAll() {
    setState(() {
      expenses.clear();
      total = 0;
    });
  }

  void checkBudget() {
    if (budgetController.text.isEmpty) return;

    double budget = double.parse(budgetController.text);

    if (total > budget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Budget exceeded!")),
      );
    }
  }

  String getTopCategory() {
    Map<String, double> map = {};

    for (var e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }

    String top = "";
    double max = 0;

    map.forEach((key, value) {
      if (value > max) {
        max = value;
        top = key;
      }
    });

    return top;
  }

  @override
  Widget build(BuildContext context) {
    double avg = expenses.isEmpty ? 0 : total / expenses.length;

    double budget = budgetController.text.isEmpty
        ? 0
        : double.parse(budgetController.text);

    double percent = (budget == 0) ? 0 : (total / budget).clamp(0, 1);

    bool exceeded = total > budget && budget > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Expense Tracker"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// Budget Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Daily Budget",
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: percent,
                        minHeight: 8,
                        color: exceeded ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Add Expense Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Expense Amount",
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: ["Food", "Transport", "Shopping", "Bills"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: addExpense,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Expense"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Expense List
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text(expenses[index].category),
                        subtitle:
                            Text("\$${expenses[index].amount.toString()}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteExpense(index),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Stats Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text("Total: \$${total.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18)),
                      Text("Average: ${avg.toStringAsFixed(2)}"),
                      Text("Count: ${expenses.length}"),
                      Text("Top: ${getTopCategory()}"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Reset Button
              ElevatedButton.icon(
                onPressed: resetAll,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}