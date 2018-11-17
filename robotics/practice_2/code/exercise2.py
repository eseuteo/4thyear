import numpy as np
import auxiliary_functions
import matplotlib.pyplot as plt

def differential_model(pose, motion, dif_t):
    s_x = np.sin(pose[2])[0]
    c_x = np.cos(pose[2])[0]
    s_nx = np.sin(pose[2] + motion[1] * dif_t)[0]
    c_nx = np.cos(pose[2] + motion[1] * dif_t)[0]

    if motion[1] == 0:
        new_pose_0 = pose[0] + motion[0] * dif_t * c_x
        new_pose_1 = pose[1] + motion[0] * dif_t * s_x
        new_pose_2 = pose[2]
    else:
        curvature_ratius = motion[0]/motion[1]
        new_pose_0 = pose[0] - curvature_ratius * s_x + curvature_ratius * s_nx
        new_pose_1 = pose[1] + curvature_ratius * c_x - curvature_ratius * c_nx
        new_pose_2 = pose[2] + motion[1] * dif_t
    return np.array([new_pose_0, new_pose_1, new_pose_2])
        
def differential_motion_velocity():
    dif_t = 0.1
    linear_velocity = 1
    robot_width_by_2 = 0.5
    sigma_linear_velocity = 0.1
    sigma_angular_velocity = 0.1
    n_steps = 800

    pose = np.array([[0], [0], [0]])
    pose_true = pose
    pose_cov_matrix = np.diag([0.2, 0.4, 0])
    motion_cov_matrix = np.diag([sigma_linear_velocity**2, sigma_angular_velocity**2])
    axis = np.array([-20, 20, -10, 30])

    fig = plt.figure(0)
    ax = fig.add_subplot(111, aspect='equal')
    plt.xlabel('x')
    plt.ylabel('y')
    plt.grid(axis='both')
    plt.xlim(axis[0:2])
    plt.ylim(axis[2:])
    plt.title('Differential-Drive Model based on velocity')

    for k in range(n_steps):
        motion = np.array([[linear_velocity], [np.pi / 10 * np.sin(4 * np.pi * (k+1) / n_steps)]])
        curvature_ratius = motion[0]/motion[1]

        s_x = np.sin(pose[2])[0]
        c_x = np.cos(pose[2])[0]
        s_u = np.sin(motion[1] * dif_t)[0]
        c_u = np.cos(motion[1] * dif_t)[0]

        if motion[1] == 0:
            jac_pose = np.array([   [1, 0, -motion[0][0] * dif_t * s_x], 
                                    [0, 1, motion[0][0] * dif_t * c_x], 
                                    [0, 0, 1]])
            jac_motion = np.array([ [dif_t * c_x, dif_t * s_x, 0], 
                                    [0, 0, 0]])
        else:
            jac_pose = np.array([   [1, 0, curvature_ratius * (-s_x * s_u - c_x * (1 - c_u))], 
                                    [0, 1, curvature_ratius * (c_x * s_u - s_x * (1 - c_u))], 
                                    [0, 0, 1]])
            jac_motion_1 = np.array([   [c_x * s_u - s_x * (1 - c_u), curvature_ratius * (c_x * c_u - s_x * s_u)], 
                                        [s_x * s_u + c_x * (1 - c_u), curvature_ratius * (s_x * c_u - c_x * s_u)], 
                                        [0, 1]])
            jac_motion_2 = np.array([   [1/motion[1][0], -motion[0][0]/(motion[1][0]**2)], 
                                        [0, dif_t]])
            jac_motion = np.dot(jac_motion_1, jac_motion_2)

        x1, y1 = np.random.randn(2,1,1)
        x1 *= sigma_linear_velocity
        y1 *= sigma_linear_velocity
        motion_true = np.array([*x1, *y1])
        pose_true = differential_model(pose_true, motion + motion_true, dif_t)
        pose = differential_model(pose, motion, dif_t)
        pose_cov_matrix = np.dot(np.dot(jac_pose, pose_cov_matrix), jac_pose.T) + np.dot(np.dot(jac_motion, motion_cov_matrix), jac_motion.T)

        if k % 40 == 0:
            auxiliary_functions.draw_robot(pose, 'r', axis)
            ax.add_artist(auxiliary_functions.get_ellipse(pose, pose_cov_matrix, 2))
            plt.plot(pose_true[0], pose_true[1], 'ko')

differential_motion_velocity()
plt.show()
