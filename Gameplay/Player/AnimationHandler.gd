extends Node

class_name AnimationHandler

# Animation speed
const IDLE_SPEED: float = 0.3
const WALK_SPEED: float = 1.0
const SPRINT_SPEED: float = 1.4

enum STANCES {IDLE=0, WALK, SPRINT}
const ANIMATIONS := ["idle", "walk", "walk"] # One per stance
var stance: int = STANCES.IDLE
var old_stance := stance

var animator: AnimationPlayer = null


func progress_animation_stance(moving: bool, sprinting: bool):
    match stance:
        STANCES.IDLE:
            if moving:
                stance = STANCES.WALK
                if sprinting:
                    stance = STANCES.SPRINT

        STANCES.WALK:
            if not moving:
                stance = STANCES.IDLE
            elif sprinting:
                stance = STANCES.SPRINT

        STANCES.SPRINT:
            if not moving:
                stance = STANCES.IDLE
            elif not sprinting:
                stance = STANCES.WALK

    if stance == old_stance: return

    old_stance = stance
    var animation_name: String = ANIMATIONS[stance]

    match stance:
        STANCES.IDLE:
            animator.stop()
            var animation := animator.get_animation(animation_name)
            animation.loop = true
            animator.play()
            animator.play(animation_name, -1, IDLE_SPEED)

        STANCES.WALK:
            _play_walk_animation(animation_name, WALK_SPEED)

        STANCES.SPRINT:
            _play_walk_animation(animation_name, SPRINT_SPEED)

func _play_walk_animation(animation_name: String, speed: float = 1):
    if animator.current_animation != animation_name:
        animator.stop()
        var animation := animator.get_animation(animation_name)
        animation.loop = true
    animator.playback_speed = speed
    animator.play(animation_name, -1, speed)
