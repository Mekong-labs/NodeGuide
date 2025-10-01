import pygame
import random
import sys

# Khởi tạo pygame
pygame.init()

# Màn hình game
WIDTH, HEIGHT = 800, 400
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Rialo Jump")

# Màu sắc
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

# Load logo Rialo
rialo_img = pygame.image.load("rialo_logo.png")  # nhớ để cùng folder
rialo_img = pygame.transform.scale(rialo_img, (60, 60))

# Vị trí nhân vật
rialo_x = 50
rialo_y = HEIGHT - 100
rialo_vel_y = 0
gravity = 0.8

# Obstacle
obstacle_width = 40
obstacle_height = 60
obstacle_x = WIDTH
obstacle_y = HEIGHT - 100

# Score
score = 0
font = pygame.font.SysFont(None, 36)

# Clock
clock = pygame.time.Clock()

running = True
while running:
    screen.fill(WHITE)

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
            pygame.quit()
            sys.exit()

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE and rialo_y == HEIGHT - 100:
                rialo_vel_y = -15  # nhảy

    # Physics nhảy
    rialo_y += rialo_vel_y
    rialo_vel_y += gravity
    if rialo_y >= HEIGHT - 100:
        rialo_y = HEIGHT - 100

    # Di chuyển obstacle
    obstacle_x -= 7
    if obstacle_x < -obstacle_width:
        obstacle_x = WIDTH
        score += 1  # vượt qua thì + điểm

    # Vẽ Rialo
    screen.blit(rialo_img, (rialo_x, rialo_y))

    # Vẽ obstacle
    pygame.draw.rect(screen, BLACK, (obstacle_x, obstacle_y, obstacle_width, obstacle_height))

    # Check va chạm
    rialo_rect = pygame.Rect(rialo_x, rialo_y, 60, 60)
    obstacle_rect = pygame.Rect(obstacle_x, obstacle_y, obstacle_width, obstacle_height)
    if rialo_rect.colliderect(obstacle_rect):
        screen.fill(WHITE)
        text = font.render("💀 Game Over!", True, BLACK)
        screen.blit(text, (WIDTH//2 - 100, HEIGHT//2))
        pygame.display.update()
        pygame.time.delay(2000)
        running = False

    # Vẽ Score
    score_text = font.render(f"Score: {score}", True, BLACK)
    screen.blit(score_text, (10, 10))

    pygame.display.update()
    clock.tick(30)
