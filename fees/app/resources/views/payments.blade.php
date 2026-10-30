<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Fee payments | Ilm Academy</title>
</head>
<body style="font-family: Arial, sans-serif; max-width: 640px; margin: 40px auto;">
  <h1>Latest fee payments</h1>
  <table>
    <tr><th>Student</th><th>Class</th><th>Amount (Rs.)</th><th>Paid on</th></tr>
    @foreach ($payments as $p)
      <tr>
        <td>{{ $p->student_name }}</td>
        <td>{{ $p->class_name }}</td>
        <td>{{ $p->amount }}</td>
        <td>{{ $p->paid_on }}</td>
      </tr>
    @endforeach
  </table>
</body>
</html>
