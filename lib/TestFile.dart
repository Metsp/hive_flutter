    // private fun getProfileDetails(){
    //     var ref = db.collection("users").whereEqualTo("userId", FirebaseAuth.getInstance().currentUser?.uid.toString())
    //     ref.get().addOnSuccessListener {
    //         if (it.isEmpty){
    //             Toast.makeText(activity, "No data found", Toast.LENGTH_SHORT).show()
    //         }
    //         for (doc in it){
    //             userAge = "${doc.get("age")}"
    //             userHeight = "${doc.get("height")}"
    //             userWeight = "${doc.get("weight")}"
    //             userGender = "${doc.get("gender")}"
    //             userBmi = "${doc.get("bmi")}"
    //             userIbw = "${doc.get("idealBodyWeight")}"


    //             // Setting BMI data
    //             var bmi = userBmi.toDouble()
    //             var status = "empty"
    //             var result = "empty"

    //             binding.tvBmi.text = userBmi

                // if (bmi < 18.5){
                //     status = "Status: Underweight"
                //     result = "You are underweight, your goal should be to eat more calories to gain weight."
                //     binding.tvBmiStatus.text = status
                //     binding.tvResult.text = result
                // }
                // if (bmi in 18.6..24.9){
                //     status = "Status: Normal"
                //     result = "Your BMI is in the normal range, you should maintain your weight!"
                //     binding.tvBmiStatus.text = status
                //     binding.tvResult.text = result
                // }
                // if (bmi in 26.0..34.9){
                //     status = "Status: Overweight"
                //     result = "Based on the BMI scale, you are overweight, your goal should be to eat less calories and lose fat."
                //     binding.tvBmiStatus.text = status
                //     binding.tvResult.text = result
                // }

                // if (bmi > 35.0){
                //     status = "Status: Obese"
                //     result = "Based on the BMI scale, you are obese, your goal should be to eat less calories and lose fat, weight as well as exercise more."
                //     binding.tvBmiStatus.text = status
                //     binding.tvResult.text = result
                // }

    //             // Setting IBW for user
    //             binding.tvIbw.text = userIbw
    //         }
    //     }
    // }

    //                         // BMI Calculation
    //                     bmi = (intWeight / (intHeightMetres * intHeightMetres))
    //                     var bmiText = String.format("%.1f", bmi)

    //                     // Ideal Body Weight Calculation
                        // if (gender == "Male"){
                        //     idealBodyWeight = 50 + (2.3 * ((intHeight * 0.3937) - 60))
                        //     ibwText = String.format("%.1f", idealBodyWeight)
                        // } else if (gender == "Female"){
                        //     idealBodyWeight = 45.5 + (2.3 * ((intHeight * 0.3937) - 60))
                        //     ibwText = String.format("%.1f", idealBodyWeight)
                        // }