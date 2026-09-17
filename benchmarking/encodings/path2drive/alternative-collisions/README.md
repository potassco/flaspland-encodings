# experimenting with `drive-collisions`

## Background

We have four encodings to try all combinations of alternative constraints.
We have two proposed constraints for vertex conflicts and two for edge conflicts.

The original constraints come from Amadé's encoding `path2drive/drive-collisions.lp`.
The alternative constraints come from Torsten's encoding `move2drive/move-collisions.lp`. 

In `drive-collisions-0.lp`:
* Amadé's `path2drive/drive-collisions.lp` **vertex constraint**
* Amadé's `path2drive/drive-collisions.lp` **edge constraint**

In `drive-collisions-1.lp`:
* Amadé's `path2drive/drive-collisions.lp` **vertex constraint**
* Torsten's `move2drive/drive-collisions.lp` **edge constraint**

In `drive-collisions-2.lp`:
* Torsten's `move2drive/drive-collisions.lp` **vertex constraint**
* Amadé's `path2drive/drive-collisions.lp `**edge constraint**

In `drive-collisions-2.lp`:
* Torsten's `move2drive/drive-collisions.lp` **vertex constraint**
* Torsten's `move2drive/drive-collisions.lp` **edge constraint**

---

## Initial results

To verify the syntax and to get an idea of their comparative performance, we test on a smaller setting.
We take the benchmark environment `Test_00/Level_0.lp` and start by keeping only four trains (`train(0)`, `train(1)`, `train(2)`, `train(3)`).
Further investigation will verify the correctness of the solutions.

The preliminary results don't show much difference between the approaches:

| approach                | time    | solving |
|-------------------------|---------|---------|
| `drive-collisions-0.lp` | 35.431s | 1.91s   |
| `drive-collisions-1.lp` | 34.908s | 1.94s   |
| `drive-collisions-2.lp` | 35.034s | 1.92s   |
| `drive-collisions-3.lp` | 35.180s | 1.92s   |

An additional train will be added along with an extended global horizon.