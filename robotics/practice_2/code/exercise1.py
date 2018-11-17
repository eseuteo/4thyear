import numpy as np
import matplotlib.pyplot as plt
import auxiliary_functions

# Exercise 1
# # n_steps = 15
# # inc = 2
# # ang = np.pi/2
# # t = np.array([inc, 0])
# # pose = np.array([[0], [0], [ang]])

# # fig = plt.figure(1)
# # axis = np.array([-2, 10, -2, 10])
# # plt.grid(axis='both')
# # plt.xlim(axis[0:2])
# # plt.ylim(axis[2:])
# # plt.title("Testing the composition of poses")

# # auxiliary_functions.draw_robot(pose, 'r', axis)

# # for i in range(n_steps):
# #     if not np.mod(i+1, 4) == 0:
# #         ang = 0    
# #     else:
# #         ang = - np.pi / 2
# #     pose_inc = np.append(t, ang)
# #     pose_inc.shape = (3,1)
# #     pose = auxiliary_functions.tcomp(pose, pose_inc)
# #     auxiliary_functions.draw_robot(pose, 'r', axis)
# # plt.show()

# Exercise 2
n_steps = 15
inc = 2
ang = np.pi/2
t = np.array([inc, 0])
pose = np.array([[0], [0], [ang]])
noise_pose = original_pose = pose

axis = np.array([-2, 10, -2, 10])
fig = plt.figure(1)
plt.grid(axis='both')
plt.xlim(axis[0:2])
plt.ylim(axis[2:])
plt.title("Testing robot's blood alcohol level")

auxiliary_functions.draw_robot(pose, 'b', axis)
for i in range(n_steps):
    if not np.mod(i+1, 4) == 0:
        ang = 0
    else:
        ang = -np.pi / 2
    pose_inc = np.append(t, ang)
    pose_inc.shape = (3,1)
    original_pose = auxiliary_functions.tcomp(original_pose, pose_inc)
    noise_pose = auxiliary_functions.tcomp(noise_pose, auxiliary_functions.add_noise(pose_inc))
    auxiliary_functions.draw_robot(original_pose, 'r', axis)
    auxiliary_functions.draw_robot(noise_pose, 'b', axis)
plt.show()