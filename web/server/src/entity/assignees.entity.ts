import { Entity, JoinColumn, ManyToOne, PrimaryColumn } from "typeorm";
import IssueEntity from "./issue.entity";
import UserEntity from "./user.entity";

@Entity("Assignees")
class AssigneesEntity {
  @PrimaryColumn()
  userId!: number;

  @PrimaryColumn()
  issueId!: number;

  @ManyToOne(() => UserEntity, (user) => user.assignees, {
    onUpdate: "CASCADE",
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "userId", referencedColumnName: "id" })
  user!: UserEntity;

  @ManyToOne(() => IssueEntity, (issue) => issue.assignees, {
    onUpdate: "CASCADE",
    onDelete: "CASCADE",
  })
  @JoinColumn({
    name: "issueId",
    referencedColumnName: "id",
  })
  issue!: IssueEntity;
}

export default AssigneesEntity;
