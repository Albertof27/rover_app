import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rover_app/state/ble_state.dart';
import 'package:rover_app/state/ble_controller_provider.dart' as providers;
import 'package:rover_app/ui/trip_logger_page.dart';
import '../state/auth_providers.dart';

class RoverHome extends ConsumerWidget {
  const RoverHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final weight     = ref.watch(weightProvider);
    final weightStr  = ref.watch(weightStringProvider);
    final overloaded = ref.watch(isOverloadedProvider);
    final threshold  = ref.watch(weightThresholdProvider);

    final conn     = ref.watch(connectionStateProvider);
    final rssi     = ref.watch(rssiProvider);
    final distance = ref.watch(distanceMetersProvider);
    final outRange = ref.watch(outOfRangeProvider);
    final ble = ref.watch(providers.bleControllerProvider);

    Color statusColor() {
      if (conn == 'connected') {
        return outRange ? Colors.red : Colors.green;
      }
      if (conn == 'scanning' || conn == 'connecting') {
        return Colors.orange;
      }
      return Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rover Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Trip Logger',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TripLoggerPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out')),
                );
              }
            },
          ),
        ],
      ),


      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Connection pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: statusColor(), width: 1),
                    ),
                    child: Text(
                      'Connection: $conn',
                      style: TextStyle(
                        color: statusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // RSSI & Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RSSI', style: Theme.of(context).textTheme.bodyLarge),
                      Text(rssi == null ? '-- dBm' : '$rssi dBm'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance', style: Theme.of(context).textTheme.bodyLarge),
                      Text(distance == null ? '-- m' : '${distance.toStringAsFixed(2)} m'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('6-ft Status', style: Theme.of(context).textTheme.bodyLarge),
                      Text(
                        outRange ? 'OUT OF RANGE' : 'OK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: outRange ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weight', style: Theme.of(context).textTheme.bodyLarge),
                      Text(weightStr), // e.g., "13.4 lbs"
                    ],
                  ),
                  const SizedBox(height: 8),
                  //overload
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Overloaded?', style: Theme.of(context).textTheme.bodyLarge),
                      Text(
                        overloaded ? 'YES (> ${threshold.toStringAsFixed(1)} lb)' : 'No',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: overloaded ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),



                  const SizedBox(height: 24),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: conn == 'connected' ? null : () => ble.scanAndConnect(),
                        icon: const Icon(Icons.bluetooth_searching),
                        label: const Text('Scan & Connect'),
                      ),
                      ElevatedButton.icon(
                        onPressed: conn == 'connected' ? () => ble.disconnect() : null,
                        icon: const Icon(Icons.link_off),
                        label: const Text('Disconnect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



