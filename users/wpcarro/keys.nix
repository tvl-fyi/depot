# wpcarro's public SSH keys
{ ... }:

rec {
  diogenes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFDRfpNXDxQuTJAqVg8+Mm/hOfE5VAJP+Lpw9kA5cDG wpcarro@gmail.com";
  marcus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkNQJBXekuSzZJ8+gxT+V1+eXTm3hYsfigllr/ARXkf wpcarro@gmail.com";
  seneca = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSVqb0ehIxp33j8wJgPoCcd45NPnZ3CisDlcO1f5isTvOTSLVf5WAdqgDk9fuTTcOMdaiPQcun7psZYEZ7EnoiDYiNM/iYoqN5ga0MdQVCU0pvkJuExuK8MqdwAnjwrLx1bqw8ivXxbmrKMyN/fUsG8I7IzC+D61ycbMwxM5qSz2mgQjzHIhpS1HgCPJXchD3jo1kw9FgSVMAJJMGpWU6BcJsQ2cNTb3W8Kg3kdeahcIssysC6TbD2MFCI6ucPOdBvP/nMHQ/zwK3CgR75M57lyzqDPqu29OpiFacefN8Jxjgwlg4h/TP3tCkb+fSV/5vkBl8aagoPb+nepC5AWF9ADsagJ6y7HYRqkXnI6FaYRbHg+NjcEu1ljYQqAIl8lRLcVqFEHfqll1V12f1UeciNoSrOBXpb0pQrUs4YlaZU1rbq0t9dQob5x+mm5BrhNhKagEvx5nV+X5bxPywCLpdrotjKpW1oS+EssRq75cv9Aw2vqdNmk2pLhgKkOJu5RrOuitHL9Ts7ax6Co5S086BT57g3BCjaiCZDoWUSRTPc6K+rDPriCGXJqfGncdUJh20QsZPYIrWQSSJuRDW59WxnNbKvIH5aFvHM2S+HyjhZC+d5pjm9mhfHuluL9+Hwis7kxlqNoX3i/i5ufGEODaLeRu5xWp0hc5fYype8BL+NNw== wpcarro@gmail.com";
  svl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd/MvQ6aNbBn1OOmir2Le4A8/DCliisb38wDEXqCRfh wpcarro@gmail.com";

  all = [ diogenes marcus seneca svl ];
}
