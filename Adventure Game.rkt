#lang racket

(require racket/string)
(require racket/list)


(define-struct game (current-location inventory locations))
(define-struct location (name description connections items locked-connections key-requirements))
(define-struct item (name visible? picked-up? type))


; Define the items
(define final-flame
  (make-item "final flame" #false #false 'flame))

(define meat
  (make-item "meat" #true #false 'food ))

(define golden-key
  (make-item "golden key" #true #false 'key))

; Define each location with items included in the list for Throne Room
(define entrance-gate
  (make-location
   "Entrance Gate"
   "You stand before a towering gate encased in ice. You can only go north from here."
   (hash 'north 'frozen-hallway)
   '() 
   (hash)
   (hash)))


(define frozen-hallway
  (make-location
   "Frozen Hallway"
   "A long, echoing hallway adorned with statues. You can go east, or south from here. The door to the north is locked."
   (hash 'south 'entrance-gate 'north 'throne-room 'east 'guards-chamber)
   (list final-flame)
   (hash 'north #t)
   (hash 'north "golden key")))

(define guards-chamber
  (make-location
   "Guard's Chamber"
   "A cold, desolate chamber with remnants of ancient guards. You can only go west from here"
   (hash 'west 'frozen-hallway)
   (list final-flame golden-key)
   (hash)  ; No locked connections.
   (hash)))

(define throne-room
  (make-location
   "Throne Room"
   "The majestic throne room, where the flames are rumored to be hidden. You can only go south from here"
   (hash 'south 'frozen-hallway)
   (list final-flame meat)
   (hash) 
   (hash)))  

; Map of all locations
(define locations
  (hash 'entrance-gate entrance-gate
        'frozen-hallway frozen-hallway
        'guards-chamber guards-chamber
        'throne-room throne-room))


(define initial-game-state
  (make-game
   'entrance-gate
   '()
   locations))

(define (move direction game)
  (let* ((current-location (game-current-location game))
         (location (hash-ref (game-locations game) current-location))
         (connections (location-connections location))
         (locked-connections (location-locked-connections location))
         (key-requirements (location-key-requirements location))
         (inventory (game-inventory game))
         (has-key (and (hash-has-key? key-requirements direction)
                       (member (hash-ref key-requirements direction)
                               (map item-name inventory)))))
    (cond
      ;; Check if direction is locked and if player has the key
      [(and (hash-has-key? connections direction)
            (hash-ref locked-connections direction #f))  ; Is direction locked?
       (if has-key
           (begin
             (display "You use the ")
             (display (hash-ref key-requirements direction))
             (display " and unlock the path.\n")
             (make-game (hash-ref connections direction) inventory (game-locations game)))
           (begin
             (display "The path to the north is locked. You need the ")
             (display (hash-ref key-requirements direction))
             (display " to proceed.\n")
             game))]
      ;; Normal movement if not locked
      [(hash-has-key? connections direction)
       (make-game (hash-ref connections direction) inventory (game-locations game))]
      ;; Default case if direction not available
      [else
       (begin
         (display "You can't go that way.\n")
         game)])))


(define (search-location game)
  (let* ((current-location-symbol (game-current-location game))
         (current-location (hash-ref (game-locations game) current-location-symbol))
         (updated-items (map (lambda (item)
                               (make-item (item-name item) #true (item-picked-up? item) (item-type item)))  
                             (location-items current-location)))
         (updated-location (make-location
                            (location-name current-location)
                            (location-description current-location)
                            (location-connections current-location)
                            updated-items
                            (location-locked-connections current-location)  
                            (location-key-requirements current-location)))  ; Preserve key requirements
         (updated-locations (hash-set (game-locations game) current-location-symbol updated-location)))
    (make-game (game-current-location game) (game-inventory game) updated-locations)))


(define (pick-up-item target-item-name game)
  (let* ((current-location-symbol (game-current-location game))
         (current-location (hash-ref (game-locations game) current-location-symbol))
         (items (location-items current-location))
         (item-to-pick-up (findf (lambda (item) 
                                   (and (string=? (item-name item) target-item-name)
                                        (item-visible? item)
                                        (not (item-picked-up? item))))
                                 items)))
    (if item-to-pick-up
        (let ((new-items (filter (lambda (item) (not (eq? item item-to-pick-up))) items))
              (new-inventory (cons (make-item (item-name item-to-pick-up) #true #true (item-type item-to-pick-up)) (game-inventory game))))
          (make-game
           (game-current-location game)
           new-inventory
           (hash-set (game-locations game) current-location-symbol 
                     (make-location
                      (location-name current-location)
                      (location-description current-location)
                      (location-connections current-location)
                      new-items
                      (location-locked-connections current-location)
                      (location-key-requirements current-location)))))
        (begin
          (display "Item not found or not pickable.\n")
          game))))


(define (drop-item target-item-name game)
  (let* ((current-location-symbol (game-current-location game))
         (current-location (hash-ref (game-locations game) current-location-symbol))
         (inventory (game-inventory game))
         (item-to-drop (findf (lambda (item) (string=? (item-name item) target-item-name))
                              inventory)))
    (if item-to-drop
        (let ((new-inventory (filter (lambda (item) (not (eq? item item-to-drop))) inventory))
              (new-items (cons (make-item (item-name item-to-drop) #true #false (item-type item-to-drop))
                               (location-items current-location))))
          (make-game
           current-location-symbol
           new-inventory
           (hash-set (game-locations game) current-location-symbol 
                     (make-location
                      (location-name current-location)
                      (location-description current-location)
                      (location-connections current-location)
                      new-items
                      (location-locked-connections current-location)
                      (location-key-requirements current-location)))))
        (begin
          (display "Item not found in inventory or not droppable.\n")
          game))))




(define (display-inventory game)
  (if (null? (game-inventory game))
      (display "Your inventory is empty.\n")
      (begin
        (display "You have the following items in your inventory:\n")
        (for-each (lambda (item)
                    (display "- ")
                    (display (item-name item))
                    (display "\n"))
                  (game-inventory game)))))

(define (process-command command game)
  (let ((tokens (string-split (string-trim (string-downcase command)))))
    (cond
      [(member (first tokens) '("north" "south" "east" "west"))
       (move (string->symbol (first tokens)) game)]
      [(and (>= (length tokens) 2) (equal? (first tokens) "pick") (equal? (second tokens) "up"))
       (pick-up-item (string-join (drop tokens 2) " ") game)]
      [(and (>= (length tokens) 2) (equal? (first tokens) "drop"))
       (drop-item (string-join (drop tokens 1) " ") game)]
      [(string=? (first tokens) "search") (search-location game)]
      [(string=? (first tokens) "look") game]
      [(string=? (first tokens) "inventory") (display-inventory game) game]
      [(string=? (first tokens) "help") (display-help) game]
      [(string=? (first tokens) "quit")
       (begin (display "Exiting game.\n") (exit))]
      [else
       (begin
         (display "Invalid command. Try 'north', 'south', 'east', 'west', 'pick up [item]', 'drop [item]', 'inventory', 'look', 'search', 'help', or 'quit'.\n")
         game)])))



(define (display-help)
  (display "To win you must search for the three final flames")
  (display "Available commands:\n")
  (display "- 'north', 'south', 'east', 'west': move in a direction.\n")
  (display "- 'search': search the current location for flames.\n")
  (display "- 'look': re-display the current location description.\n")
  (display "- 'pick up [item]': pick up an item in the current location.\n")
  (display "- 'drop [item]': drop an item at the current location.\n")
  (display "- 'inventory': Show the items you are carrying.\n")
  (display "- 'help': display this help message.\n")
  (display "- 'quit': exit the game.\n"))

(define (display-location game)
  (let* ((current-location-symbol (game-current-location game))
         (current-location (hash-ref (game-locations game) current-location-symbol))
         (directions (map symbol->string (hash-keys (location-connections current-location))))
         (visible-items (filter (lambda (item) (item-visible? item)) (location-items current-location))))  ; Filter to only visible items
    (printf "~a\nDirections: ~a\n" (location-description current-location) (string-join directions ", "))
    (unless (null? visible-items)
      (printf "You see here: ~a\n" (string-join (map item-name visible-items) ", ")))))  ; Only show names of visible items

(define (check-win-condition game)
  (let ((current-location (game-current-location game))
        (inventory-items (map item-name (game-inventory game))))
    (and (eq? current-location 'entrance-gate)  ; Check if player is at the entrance gate
         (>= (count (lambda (item-name) (string=? item-name "final flame")) inventory-items) 3))))  ; Check for three Final Flames

(define (game-loop game)
  (if (check-win-condition game)
      (display "You have returned fire to the world! Finally Ending the eternal winter!\n")  ; Display win message and end game
      (let* ((command (string-trim (string-downcase (read-line))))
             (new-game (process-command command game)))
        (display-location new-game) 
        (game-loop new-game))))



(define (start-game)
  (display "You must search for the three final flames from the ice fortress and return here to stop the eternal winter.\nType help at any time for more information.\n")
  (display-location initial-game-state)  ; Display initial location description
  (game-loop initial-game-state))

(start-game)