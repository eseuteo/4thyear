import auxiliary_functions
import numpy as np
import matplotlib.pyplot as plt

# Exercise 1
# # n_steps = 15
# # t = np.array([0, 0])
# # inc = 2
# # ang = np.pi/2
# # pose = np.array([[0], [0], [ang]])
# # axis = np.array([-2, 10, -2, 10])

# # P = np.diag([0,0,0])
# # Q = np.diag([.04, .04, .01])

# # xtrue = pose

# # fig = plt.figure(1)
# # ax = fig.add_subplot(111, aspect='equal')
# # plt.grid(axis='both')
# # plt.xlim(-2, 10)
# # plt.ylim(-2, 10)
# # plt.title("Differential motion with odometry commands")

# # plt.plot(xtrue[0], xtrue[1], 'ko', mfc='none')
# # auxiliary_functions.draw_robot(pose, 'r', axis)

# # for i in range(n_steps):
# #     t = np.array([inc, 0])
# #     if not np.mod(i+1, 4) == 0:
# #         ang = 0
# #     else:
# #         ang = - np.pi / 2
# #     pose_inc = np.append(t, ang)
# #     pose_inc.shape = (3,1)
# #     cx = np.cos(pose[2])[0]
# #     sx = np.sin(pose[2])[0]

# #     jac_x = np.array([  [1, 0, - t[0] * sx - t[1] * cx], 
# #                         [0, 1, t[0] * cx - t[1] * sx], 
# #                         [0, 0, 1]])
# #     jac_u = np.array([  [cx, -sx, 0],
# #                         [sx, cx, 0],
# #                         [0, 0, 1]])

# #     P = np.dot(np.dot(jac_x, P), jac_x.T) + np.dot(np.dot(jac_u, Q), jac_u.T)

# #     pose = auxiliary_functions.tcomp(pose, pose_inc)
# #     xtrue = auxiliary_functions.tcomp(xtrue, auxiliary_functions.add_noise(pose_inc))

# #     ax.add_artist(auxiliary_functions.get_ellipse(pose, P, .5))
# #     plt.plot(xtrue[0], xtrue[1], 'ko', mfc='none')
# #     auxiliary_functions.draw_robot(pose, 'r', axis)

# # plt.show()

# Exercise 2
n_steps = 8
n_particles = 100
a1, a2, a3, a4 = .01, .01, .07, .07
t = np.array([0, 0])
inc = 2
ang = np.pi/2
prev = None
pose = np.array([[0], [0], [ang]])
axis = np.array([-2, 10, -2, 10])
particles = np.zeros((n_particles, 3))
colors = ['lime', 'brown', 'cyan', 'red', 'blue', 'magenta', 'green', 'yellow']

fig = plt.figure(1)
ax = fig.add_subplot(111, aspect='equal')
plt.grid(axis='both')
plt.xlim(-2, 10)
plt.ylim(-2, 10)
plt.title("Robot position from sampling")

auxiliary_functions.draw_robot(pose, 'r', axis)

for i in range(n_steps):
    t = np.array([inc, 0])
    if not np.mod(i+1, 4) == 0:
        ang = 0
    else:
        ang = - np.pi / 2
    pose_inc = np.append(t, ang)
    pose_inc.shape = (3,1)

    prev = pose
    pose = auxiliary_functions.tcomp(pose, pose_inc)

    _ang_1, _dist, _ang_2 = auxiliary_functions.get_ut(pose, prev)

    for j in range(n_particles):
        ang_1 = _ang_1 + (a1 * _ang_1 + a2 * _dist) * np.random.randn()
        dist = _dist + (a3 * _dist + a4 * (_ang_1 + _ang_2)) * np.random.randn()
        ang_2 = _ang_2 + (a1 * _ang_2 + a2 * _dist) * np.random.randn()
        
        particles[j][0] = particles[j][0] + dist * np.cos(prev[2] + ang_1)
        particles[j][1] = particles[j][1] + dist * np.sin(prev[2] + ang_1)
        particles[j][2] = prev[2] + ang_1 + ang_2

        plot_x = np.cos(particles[j][2]) * particles[j][0] - np.sin(particles[j][2]) * particles[j][1]
        plot_y = np.sin(particles[j][2]) * particles[j][0] + np.cos(particles[j][2]) * particles[j][1]

        if i < n_steps / 2 - 1:
            plot_x, plot_y = plot_y, -plot_x
        if i == n_steps - 1:
            plot_y *= -1

        plt.plot(plot_x, plot_y, '.', color=colors[i])

    auxiliary_functions.draw_robot(pose, 'r', axis)

plt.show()