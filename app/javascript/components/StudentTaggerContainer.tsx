import React, { useState } from 'react';

import StudentTagger, { Student, Result, FailureReasons } from './StudentTagger';

interface Props {
  student: Student;
}


export default (props: Props) => {
  const [studentResult, setStudentResult] = useState<{student: Student, result: Result | undefined}>({
    student: props.student,
    result: undefined
  })

  const [isFetching, setIsFetching] = useState(false);

  const assignToken = (tokenId: string, studentId: number) => {
    if (isFetching) {
      return;
    }

    setIsFetching(true);

    if (tokenId !== '') {
      setStudentResult(r => ({...r, result: undefined }));
      
      fetch('/students/tag', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ student_id: studentId, token_id: tokenId })
        }).then(resp => resp.json())
        .then(data => {
          setIsFetching(false);

          setStudentResult({
            student: data.next_student,
            result: data.result
          });
        }).catch(e => {
          setIsFetching(false);
          setStudentResult(r => (
            {
              ...r,
              result: {
                success: false,
                reason: FailureReasons.ApiError,
                student: r.student
              }
            }
          ));
        });
    }
  }

  return <StudentTagger isFetching={isFetching} result={studentResult.result} student={studentResult.student} assignToken={assignToken} />
}

