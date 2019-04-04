sequenceDiagram
    API->>middlewares: PLAY_TURN
    middlewares-->>state: PLAY_TURN
    middlewares-->>middlewares: MOVE_OBJECTS
    middlewares-->>state: MOVE_OBJECTS
    middlewares-->>middlewares: MOVE_OBJECT
    middlewares-->>state: MOVE_OBJECT
    middlewares-->>middlewares: ASSIGN_WEAPONS_TO_FIRECONS
    middlewares-->>state: ASSIGN_WEAPONS_TO_FIRECONS
