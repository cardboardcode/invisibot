import copy
from threading import Lock

class FleetRegistry:
    """
    A thread-safe central registry for tracking the real-time positions 
    of all robots in the fleet. Enables inter-robot awareness for 
    collision avoidance.
    """
    def __init__(self):
        self._positions = {} # name -> (x, y, yaw)
        self._lock = Lock()

    def update_pose(self, name: str, x: float, y: float, yaw: float):
        with self._lock:
            self._positions[name] = (x, y, yaw)

    def get_all_poses(self) -> dict:
        with self._lock:
            return copy.deepcopy(self._positions)

    def is_collision_imminent(self, name: str, x: float, y: float, radius: float = 0.5) -> bool:
        """Checks if any other robot is within the specified collision radius."""
        with self._lock:
            for other_name, (ox, oy, _) in self._positions.items():
                if other_name == name:
                    continue
                # Euclidean distance
                distance = ((x - ox)**2 + (y - oy)**2)**0.5
                if distance < radius:
                    return True
            return False
